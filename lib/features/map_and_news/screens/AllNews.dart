import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar%20copy.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/view/dashboard/Dashboard.dart';
import 'package:presshop/utils/ShareHelper.dart';

import 'package:presshop/view/map_and_news/models/marker_model.dart';
import 'package:presshop/view/map_and_news/screens/news_details_screen.dart';
import 'package:presshop/view/menuScreen/MenuScreen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:presshop/view/map_and_news/controller/map_controller.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:pull_to_refresh/pull_to_refresh.dart';

class AllNews extends ConsumerStatefulWidget {
  const AllNews({Key? key}) : super(key: key);

  @override
  ConsumerState<AllNews> createState() => _AllNewsState();
}

class _AllNewsState extends ConsumerState<AllNews> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future<void> _onRefresh() async {
    await ref.read(mapControllerProvider.notifier).fetchAggregatedNews();
    _refreshController.refreshCompleted();
  }

  Future<void> _handleShare(BuildContext context, Incident item) async {
    await ShareHelper.handleShare(
      context: context,
      newsId: item.id,
      title: item.title ?? "News Update",
      imageUrl: item.image,
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final state = ref.watch(mapControllerProvider);
    final newsList = state.newsList ?? [];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: NewCommonAppBar(
        elevation: 0,
        hideLeading: true,
        title: Padding(
          padding: EdgeInsets.only(left: size.width * numD04),
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => Dashboard(initialPosition: 2)),
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
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MenuScreen()));
              },
              child: Container(
                padding: EdgeInsets.all(size.width * numD025),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(size.width * numD035),
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
            onRefresh: _onRefresh,
            header: const WaterDropHeader(),
            child: newsList.isEmpty && !state.isLoadingNews
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
                      return _buildNewsCard(context, newsList[index], size);
                    },
                  ),
          ),
          if (state.isLoadingNews && newsList.isEmpty)
            Container(
              color: Colors.transparent, // Explicitly transparent
              child: Center(
                child: showAnimatedLoader(size),
              ),
            ),
        ],
      ),
    );
  }

  void _toggleLike(String id) {
    ref.read(mapControllerProvider.notifier).toggleNewsLike(id);
  }

  Widget _buildNewsCard(BuildContext context, Incident item, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Section
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(size.width * numD04),
              child: CachedNetworkImage(
                imageUrl: item.image ?? "",
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
            // Video Icon Top Left (simulated)
            // Positioned(
            //   left: size.width * numD03,
            //   top: size.width * numD03,
            //   child: Container(
            //     padding: EdgeInsets.all(size.width * numD015),
            //     decoration: BoxDecoration(
            //       color: Colors.black.withOpacity(0.5),
            //       borderRadius: BorderRadius.circular(size.width * numD02),
            //     ),
            //     child: Icon(
            //       Icons.videocam_outlined,
            //       color: Colors.white,
            //       size: size.width * numD05,
            //     ),
            //   ),
            // ),
            // Most Viewed Badge
            if (item.isMostViewed == true)
              Positioned(
                left: size.width * numD03,
                bottom: size.width * numD03,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * numD03,
                      vertical: size.width * numD015),
                  decoration: BoxDecoration(
                    color: colorThemePink, // Red/Pinkish color from Common.dart
                    borderRadius: BorderRadius.circular(size.width * numD05),
                  ),
                  child: Text(
                    "Most viewed",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * numD03,
                      fontWeight: FontWeight.w600,
                      fontFamily: "AirbnbCereal",
                    ),
                  ),
                ),
              ),
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
                  // Use a simpler image for avatar or a placeholder
                  backgroundImage: const NetworkImage(
                      "https://i.pravatar.cc/150?u=a042581f4e29026704d"),
                  backgroundColor: Colors.grey[300],
                ),
                SizedBox(width: size.width * numD02),
                Text(
                  item.author ?? "Unknown",
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
        Text(item.title ?? "No Title",
            style: commonTextStyle(
                size: size,
                fontSize: size.width * numD04,
                color: Colors.black,
                lineHeight: 1.5,
                fontWeight: FontWeight.w700)),
        SizedBox(height: size.width * numD02),

        // Description
        Text(
          item.description ?? "",
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
                false
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
                  final timeStr = item.time;
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

                  String displayTime = timeStr;
                  try {
                    displayTime = DateFormat('hh:mm a')
                        .format(DateFormat("HH:mm").parse(timeStr));
                  } catch (_) {}

                  return Text(
                    displayTime,
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
                  if (item.date != null) {
                    parsedDate = DateTime.tryParse(item.date!);
                  }
                  if (parsedDate == null && item.time != null) {
                    parsedDate = DateTime.tryParse(item.time!);
                  }

                  return Text(
                    parsedDate != null
                        ? DateFormat("dd MMM yyyy").format(parsedDate)
                        : (item.date ?? ""),
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
                item.address ?? "Unknown Location",
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
                  item.isLiked == true
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

  void _navigateToDetails(BuildContext context, Incident item,
      {bool scrollToComments = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailsScreen(
          newsId: item.id,
          initialIncident: item,
          scrollToComments: scrollToComments,
        ),
      ),
    );
  }
}
