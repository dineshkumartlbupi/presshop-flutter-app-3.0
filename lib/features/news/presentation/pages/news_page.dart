import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:presshop/core/constants/app_assets.dart';
import 'package:presshop/core/constants/app_dimensions.dart';
import 'package:presshop/core/di/injection_container.dart';

import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';
import 'package:presshop/features/menu/presentation/pages/menu_screen.dart';
import 'package:presshop/features/news/domain/entities/news.dart';
import 'package:presshop/features/news/presentation/bloc/news_bloc.dart';
import 'package:presshop/features/news/presentation/bloc/news_event.dart';
import 'package:presshop/features/news/presentation/bloc/news_state.dart';
import 'package:presshop/features/news/presentation/pages/news_details_screen_legacy.dart';
import 'package:presshop/core/utils/ui_utils.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (_) => sl<NewsBloc>()
        ..add(const GetAggregatedNewsEvent(
          lat: 0, // TODO: Get actual location
          lng: 0,
          km: 50,
        )),
      child: BlocConsumer<NewsBloc, NewsState>(
        listener: (context, state) {
          if (!state.isLoading) {
            _refreshController.refreshCompleted();
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          final newsList = state.newsList;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: CommonAppBar(
              elevation: 0,
              hideLeading: true,
              title: Padding(
                padding: EdgeInsets.only(left: size.width * numD04),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) =>
                                Dashboard(initialPosition: 2)),
                        (route) => false);
                  },
                  child: Image.asset(
                    "${commonImagePath}rabbitLogo.png",
                    height: size.width * numD10,
                    width: size.width * numD10,
                  ),
                ),
              ),
              centerTitle: false,
              titleSpacing: 0,
              size: size,
              showActions: true,
              leadingFxn: () {
                Navigator.pop(context);
              },
              actionWidget: [
                SizedBox(
                  width: size.width * numD02,
                ),
                Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MenuScreen()));
                    },
                    child: Container(
                      padding: EdgeInsets.all(size.width * numD025),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius:
                            BorderRadius.circular(size.width * numD035),
                      ),
                      child: Image.asset(
                        'assets/icons/menu3.png',
                        width: size.width * numD06,
                        height: size.width * numD06,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: size.width * numD04,
                )
              ],
            ),
            body: Stack(
              children: [
                SmartRefresher(
                  controller: _refreshController,
                  enablePullDown: true,
                  enablePullUp: false,
                  onRefresh: () {
                    context.read<NewsBloc>().add(const GetAggregatedNewsEvent(
                          lat: 0, // TODO: Get actual location
                          lng: 0,
                          km: 50,
                        ));
                  },
                  header: const WaterDropHeader(),
                  child: newsList.isEmpty && !state.isLoading
                      ? Center(
                          child: Text(
                            "No news found",
                            style: TextStyle(
                              fontSize: size.width * numD04,
                              color: Colors.black,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.all(size.width * numD04),
                          itemCount: newsList.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: size.width * numD06),
                          itemBuilder: (context, index) {
                            return _buildNewsCard(
                                context, newsList[index], size);
                          },
                        ),
                ),
                if (state.isLoading && newsList.isEmpty)
                  Container(
                    color: Colors.transparent,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _toggleLike(String id) {
    // TODO: Implement toggle like in NewsBloc
    // context.read<NewsBloc>().add(ToggleNewsLikeEvent(id));
  }

  Future<void> _handleShare(BuildContext context, News item) async {
    await shareLink(
      title: item.title,
      description: item.description,
      taskName: "News",
    );
  }

  Widget _buildNewsCard(BuildContext context, News item, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Section
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(size.width * numD04),
              child: CachedNetworkImage(
                imageUrl: item.mediaUrl ?? "",
                height: size.width * numD50,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: size.width * numD50,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: size.width * numD50,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            // Most Viewed Badge (assuming isMostViewed is not in News entity, using viewCount logic or omitting)
            // if (item.viewCount != null && item.viewCount! > 1000) // Example logic
            //   Positioned(
            //     left: size.width * numD03,
            //     bottom: size.width * numD03,
            //     child: Container(
            //       padding: EdgeInsets.symmetric(
            //           horizontal: size.width * numD03,
            //           vertical: size.width * numD015),
            //       decoration: BoxDecoration(
            //         color: colorThemePink,
            //         borderRadius: BorderRadius.circular(size.width * numD05),
            //       ),
            //       child: Text(
            //         "Most viewed",
            //         style: TextStyle(
            //           color: Colors.white,
            //           fontSize: size.width * numD03,
            //           fontWeight: FontWeight.w600,
            //           fontFamily: "AirbnbCereal",
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        ),
        SizedBox(height: size.width * numD03),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: size.width * numD035,
                  backgroundImage: NetworkImage(item.userImage ??
                      "https://i.pravatar.cc/150?u=a042581f4e29026704d"),
                  backgroundColor: Colors.grey[300],
                ),
                SizedBox(width: size.width * numD02),
                Text(
                  item.userName ?? "Unknown",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: size.width * numD035,
                    fontFamily: "AirbnbCereal",
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: size.width * numD03),

        // Title
        Text(item.title,
            style: commonTextStyle(
                size: size,
                fontSize: size.width * numD04,
                color: Colors.black,
                lineHeight: 1.5,
                fontWeight: FontWeight.w700)),
        SizedBox(height: size.width * numD02),

        // Description
        Text(
          item.description,
          textAlign: TextAlign.justify,
          style: commonTextStyle(
              size: size,
              fontSize: size.width * numD03,
              color: Colors.black,
              lineHeight: 2,
              fontWeight: FontWeight.normal),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: size.width * numD04),

        Row(
          children: [
            _buildStatItem(
              Image.asset(
                (item.isLiked ?? false)
                    ? "assets/icons/new_heartfill.png"
                    : "assets/icons/news_heart.png",
                width: size.width * numD03,
                height: size.width * numD03,
                color: Colors.grey[600],
              ),
              "${item.likesCount ?? 0}",
              "likes",
              size,
              color: Colors.grey[500],
            ),

            SizedBox(width: size.width * numD02),
            _buildStatItem(
              Image.asset(
                "assets/icons/news_eye.png",
                width: size.width * numD04,
                height: size.width * numD04,
                color: Colors.grey[500],
              ),
              "${item.viewCount ?? 0}",
              "views",
              size,
              color: Colors.grey[500],
            ),
            SizedBox(width: size.width * numD02),

            // Time
            Row(
              children: [
                Image.asset(
                  "${iconsPath}ic_clock.png",
                  height: size.width * numD03,
                  color: Colors.grey[500],
                ),
                SizedBox(width: size.width * numD01),
                Builder(builder: (context) {
                  final timeStr = item.createdAt;
                  if (timeStr == null) return const SizedBox();

                  DateTime? parsed = DateTime.tryParse(timeStr);
                  if (parsed != null) {
                    return Text(
                      DateFormat('hh:mm a').format(parsed),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w400,
                        fontSize: size.width * numD032,
                        fontFamily: "AirbnbCereal",
                      ),
                    );
                  }
                  return Text(
                    timeStr,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                      fontSize: size.width * numD032,
                      fontFamily: "AirbnbCereal",
                    ),
                  );
                }),
              ],
            ),
            SizedBox(width: size.width * numD02),

            // Date
            Row(
              children: [
                Image.asset(
                  "${iconsPath}ic_yearly_calendar.png",
                  height: size.width * numD03,
                  color: Colors.grey[500],
                ),
                SizedBox(width: size.width * numD01),
                Builder(builder: (context) {
                  DateTime? parsedDate;
                  if (item.createdAt != null) {
                    parsedDate = DateTime.tryParse(item.createdAt!);
                  }

                  return Text(
                    parsedDate != null
                        ? DateFormat("dd MMM yyyy").format(parsedDate)
                        : (item.createdAt ?? ""),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                      fontSize: size.width * numD032,
                      fontFamily: "AirbnbCereal",
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
        SizedBox(height: size.width * numD02),

        // Date and Location
        Row(
          children: [
            Image.asset("assets/icons/news_location.png",
                height: size.width * numD04, color: Colors.grey[500]),
            SizedBox(width: size.width * numD01),
            Expanded(
              child: Text(
                item.location ?? "Unknown Location",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: size.width * numD03,
                    color: Colors.grey[500],
                    fontFamily: "AirbnbCereal"),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: size.width * numD04),

        // Action Buttons Row
        Row(
          children: [
            InkWell(
              onTap: () => _toggleLike(item.id),
              child: Image.asset(
                  (item.isLiked ?? false)
                      ? "assets/icons/new_heartfill.png"
                      : "assets/icons/news_heart.png",
                  width: size.width * numD06,
                  height: size.width * numD05),
            ),
            SizedBox(width: size.width * numD04),
            Builder(builder: (context) {
              return InkWell(
                onTap: () {
                  _handleShare(context, item);
                },
                child: Image.asset("assets/icons/news_send.png",
                    width: size.width * numD06, height: size.width * numD05),
              );
            }),
            SizedBox(width: size.width * numD04),
            InkWell(
              onTap: () {
                _navigateToDetails(context, item, scrollToComments: true);
              },
              child: Image.asset("assets/icons/news_message.png",
                  width: size.width * numD06, height: size.width * numD05),
            ),

            const Spacer(),

            // Read More Button
            InkWell(
              onTap: () {
                _navigateToDetails(context, item);
              },
              child: Text(
                "Read More",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: size.width * numD035,
                  // decoration: TextDecoration.underline,
                  fontFamily: "AirbnbCereal",
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: size.width * numD02),
        const Divider(),
      ],
    );
  }

  Widget _buildStatItem(Image icon, String value, String label, Size size,
      {Color? color}) {
    return Row(
      children: [
        icon,
        SizedBox(width: size.width * numD01),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "$value ",
                style: TextStyle(
                  color: color ?? Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: size.width * numD032,
                  fontFamily: "AirbnbCereal",
                ),
              ),
              TextSpan(
                text: label,
                style: TextStyle(
                  color: color ?? Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: size.width * numD032,
                  fontFamily: "AirbnbCereal",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToDetails(BuildContext context, News item,
      {bool scrollToComments = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailsScreen(
          newsId: item.id,
          initialNews: item,
          scrollToComments: scrollToComments,
        ),
      ),
    );
  }
}
