import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:presshop/main.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkClass.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/leaderboard/leaderboard_model.dart';
import 'package:presshop/view/leaderboard/leadership_table_widget.dart';

import '../../utils/Common.dart';
import '../dashboard/Dashboard.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<StatefulWidget> createState() => LeaderboardScreenState();
}

class LeaderboardScreenState extends State<LeaderboardScreen>
    implements NetworkResponse {
  late Size size;
  bool isLoading = true;
  bool isError = false;
  String selectedCountryCode = "global";
  ScrollController _scrollController = ScrollController();
  LeaderboardResponse? leaderboardResponse;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLearderboardData(selectedCountryCode);
    });
    _scrollController.addListener(_onScroll);
  }

  Future<void> getLearderboardData(String countryCode) async {
    var leadershipurlData = "$leadershipurl?country=$countryCode";
    NetworkClass.fromNetworkClass(leadershipurlData, this, leadershipReq, {})
        .callRequestServiceHeader(true, "get", null);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // User has scrolled to the bottom, trigger pagination
      // _loadMoreData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String getFormattedDate(DateTime dateTime) {
    try {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return "${months[dateTime.month - 1]} ${dateTime.year}";
    } catch (e) {
      return dateTime.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          "Leaderboard",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size.width * appBarHeadingFontSize),
        ),
        centerTitle: false,
        titleSpacing: 0,
        size: size,
        showActions: true,
        leadingFxn: () {
          Navigator.pop(context);
        },
        actionWidget: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => Dashboard(initialPosition: 2)),
                  (route) => false);
            },
            child: Image.asset(
              "${commonImagePath}rabbitLogo.png",
              height: size.width * numD07,
              width: size.width * numD07,
            ),
          ),
          SizedBox(
            width: size.width * numD02,
          ),
        ],
      ),
      body: leaderboardResponse != null
          ? Padding(
              padding: EdgeInsets.all(size.width * numD04),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * numD10,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: leaderboardResponse!.countryList.length,
                      itemBuilder: (context, index) {
                        var countryItem =
                            leaderboardResponse!.countryList[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCountryCode = countryItem.countryCode;
                              isLoading = true;
                            });
                            getLearderboardData(selectedCountryCode);
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: size.width * numD03),
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * numD03,
                                vertical: size.width * numD015),
                            decoration: BoxDecoration(
                              color:
                                  selectedCountryCode == countryItem.countryCode
                                      ? colorThemePink
                                      : Colors.grey[300],
                              borderRadius:
                                  BorderRadius.circular(size.width * numD02),
                            ),
                            child: Center(
                              child: Text(countryItem.country,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: selectedCountryCode ==
                                              countryItem.countryCode
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (leaderboardResponse!.memberList.isEmpty) ...[
                    Padding(
                      padding: EdgeInsets.only(top: size.height * numD30),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "No Member available in this Country",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                  ] else ...[
                    SizedBox(
                      height: size.height * numD04,
                    ),
                    LeadershipTableWidget(
                      memberList:
                          leaderboardResponse?.memberList.take(3).toList() ??
                              [],
                    ),
                    SizedBox(
                      height: size.height * numD04,
                    ),
                    Text(
                        '${leaderboardResponse?.totalMember} total earning members',
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w500)),
                    Divider(
                      height: size.height * numD02,
                      thickness: 0.5,
                      color: Colors.black,
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: leaderboardResponse?.memberList.length,
                        itemBuilder: (context, index) {
                          var memberItem =
                              leaderboardResponse!.memberList[index];
                          return Padding(
                            padding:
                                EdgeInsets.only(bottom: size.height * numD02),
                            child: Row(
                              children: [
                                Container(
                                    padding: EdgeInsets.all(
                                      size.width * numD01,
                                    ),
                                    height: size.width * numD15,
                                    width: size.width * numD15,
                                    child: ClipOval(
                                      clipBehavior: Clip.antiAlias,
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            avatarImageUrl + memberItem.avatar,
                                        errorWidget: (context, url, error) {
                                          return Image.asset(
                                            "${commonImagePath}rabbitLogo.png",
                                            height: size.width * numD06,
                                            width: size.width * numD06,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                                SizedBox(
                                  width: size.width * numD03,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      memberItem.userName.toTitleCase(),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD04,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      height: size.height * numD005,
                                    ),
                                    Text(
                                      "Hopper since ${getFormattedDate(memberItem.createdAt)}",
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD032,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Text(
                                  "$currencySymbol${memberItem.totalEarnings}",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD04,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ]
                ],
              ),
            )
          : SizedBox.shrink(),
    );
  }

  @override
  void onError({Key? key, required int requestCode, required String response}) {
    switch (requestCode) {
      /// Get Room Id
      case leadershipReq:
        setState(() {
          isLoading = false;
          isError = true;
        });
        break;
    }
  }

  @override
  void onResponse(
      {Key? key, required int requestCode, required String response}) {
    switch (requestCode) {
      /// Get Room Id
      case leadershipReq:
        var data = jsonDecode(response);
        debugPrint("getRoomIdReq Success : $data");
        leaderboardResponse = LeaderboardResponse.fromJson(data);

        setState(() {
          isLoading = false;
          isError = false;
        });
        break;
    }
  }
}
