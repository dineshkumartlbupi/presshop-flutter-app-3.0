import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:presshop/utils/AllTaskModel.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/view/task_details_new_screen/task_details_new_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllTaskDemo extends StatefulWidget {
  const AllTaskDemo({super.key});

  @override
  State<AllTaskDemo> createState() => _AllTaskDemoState();
}

class _AllTaskDemoState extends State<AllTaskDemo> {
  List<AllTaskModel> taskList = [];
  bool isLoading = true;
  late Size size;

  // Pagination variables
  int limit = 10;
  int offset = 0;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    fetchTasks();
    debugPrint("AllTaskDemo: initState call");
  }

  void _onRefresh() async {
    offset = 0;
    // Don't clear list immediately to avoid flicker, or do clear if desired.
    // Usually standard is to fetch and replace.
    await fetchTasks(isRefresh: true);
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    offset += limit;
    await fetchTasks(isLoadMore: true);
    // REMOVED loadComplete() here. It crashes the "No Data" state if called after loadNoData().
    // We handle state inside fetchTasks.
  }

  Future<void> fetchTasks(
      {bool isRefresh = false, bool isLoadMore = false}) async {
    debugPrint(
        "AllTaskDemo: fetchTasks started. Offset: $offset, Limit: $limit");
    try {
      var dio = Dio();
      // Using the stored token for authentication
      final sp = await SharedPreferences.getInstance();
      String token = sp.getString(tokenKey) ?? "";
      debugPrint("AllTaskDemo: Token found: ${token.isNotEmpty}");

      dio.options.headers["Authorization"] = "Bearer $token";
      dio.options.headers["Content-Type"] = "application/json";

      // Using the specific endpoint and body requested
      debugPrint("AllTaskDemo: Making API call...");
      var response = await dio.post(
        "https://dev-api.presshop.news:5019/hopper/getAllTask",
        data: {"limit": limit, "offset": offset},
      );

      debugPrint("AllTaskDemo: Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        var data = response.data;
        debugPrint("AllTaskDemo: Data received: $data");

        if (data['data'] != null) {
          var list = (data['data'] as List)
              .map((e) => AllTaskModel.fromJson(e))
              .toList();
          debugPrint("AllTaskDemo: Parsed ${list.length} tasks");

          if (mounted) {
            setState(() {
              if (isLoadMore) {
                taskList.addAll(list);
              } else {
                // Initial load or Refresh
                taskList = list;
              }
              isLoading = false;
            });

            // Check if no more data to disable load more
            // Note: If list.length < limit, it means we reached end.
            if (list.length < limit) {
              _refreshController.loadNoData();
            } else {
              _refreshController.loadComplete();
            }
          }
        } else {
          debugPrint("AllTaskDemo: data['data'] is null");
          if (mounted) {
            setState(() {
              isLoading = false;
              if (!isLoadMore) taskList = [];
            });
            _refreshController.loadNoData();
          }
        }
      } else {
        debugPrint("Error fetching tasks: ${response.statusCode}");
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          _refreshController.loadFailed();
        }
      }
    } catch (e) {
      debugPrint("Exception fetching tasks: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        _refreshController.loadFailed();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Task Demo"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              enablePullUp: true,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              footer: const CustomFooter(builder: commonRefresherFooter),
              child: taskList.isEmpty
                  ? Center(
                      child: Text("No tasks found",
                          style: TextStyle(color: Colors.black, fontSize: 16)))
                  : GridView.builder(
                      itemCount: taskList.length,
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD04,
                          vertical: size.width * numD04),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        mainAxisSpacing: size.width * numD04,
                        crossAxisSpacing: size.width * numD04,
                      ),
                      itemBuilder: (context, index) {
                        var item = taskList[index];
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => TaskDetailNewScreen(
                                    taskStatus: item.status,
                                    taskId: item.id,
                                    totalEarning: "0")));
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                left: size.width * numD03,
                                right: size.width * numD03,
                                top: size.width * numD03),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.shade200,
                                      spreadRadius: 2,
                                      blurRadius: 1)
                                ],
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Image
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD04),
                                      child: Image.network(
                                        item.uploadContents?.videothubnail ??
                                            "",
                                        height: size.width * numD28,
                                        width: size.width,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            alignment: Alignment.topCenter,
                                            child: Image.asset(
                                              "${commonImagePath}rabbitLogo.png",
                                              height: size.width * numD26,
                                              width: size.width * numD26,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, exception, stackTrace) {
                                          return Container(
                                            alignment: Alignment.topCenter,
                                            child: Image.asset(
                                              "${commonImagePath}rabbitLogo.png",
                                              height: size.width * numD26,
                                              width: size.width * numD26,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: size.width * numD02,
                                ),

                                /// Title
                                Text(
                                  item.heading.toTitleCase(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD03,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),

                                const Spacer(),

                                /// Dead Line
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      "${iconsPath}ic_clock.png",
                                      height: size.width * numD029,
                                    ),
                                    SizedBox(
                                      width: size.width * numD01,
                                    ),
                                    Text(
                                      dateTimeFormatter(
                                          dateTime: item.createdAt.toString(),
                                          format: "hh:mm a"),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD024,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    SizedBox(
                                      width: size.width * numD018,
                                    ),
                                    Image.asset(
                                      "${iconsPath}ic_yearly_calendar.png",
                                      height: size.width * numD028,
                                    ),
                                    SizedBox(
                                      width: size.width * numD01,
                                    ),
                                    Text(
                                      dateTimeFormatter(
                                          dateTime: item.createdAt.toString(),
                                          format: "dd MMM yyyy"),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD024,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: size.width * numD013,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "TAP TO ACCEPT",
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD025,
                                          color: colorThemePink,
                                          fontWeight: FontWeight.normal),
                                    ),

                                    // Animated blinking/highlight effect
                                    // Blinking "Available" badge with infinite animation
                                    Container(
                                      alignment: Alignment.center,
                                      height: size.width * numD08,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.width * numD025,
                                          vertical: size.width * numD01),
                                      decoration: BoxDecoration(
                                          color: colorThemePink,
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD015)),
                                      child: Text(
                                        "Available",
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD025,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    )
                                  ],
                                ),

                                SizedBox(
                                  height: size.width * numD02,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
