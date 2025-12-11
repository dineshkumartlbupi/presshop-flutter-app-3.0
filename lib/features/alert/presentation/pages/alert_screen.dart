import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/features/account_settings/presentation/pages/faq_screen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:presshop/main.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';
import 'package:presshop/core/di/injection_container.dart' as di;

import '../bloc/alert_bloc.dart';
import '../bloc/alert_event.dart';
import '../bloc/alert_state.dart';
import '../../data/models/alert_model.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  RefreshController refreshController = RefreshController(initialRefresh: false);
  bool isDirection = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => di.sl<AlertBloc>()
        ..add(const FetchAlertsEvent())
        ..add(GetCurrentLocationEvent()),
      child: BlocConsumer<AlertBloc, AlertState>(
        listener: (context, state) {
          if (state.status == AlertStatus.success || state.status == AlertStatus.failure) {
             // Handle SmartRefresher state
             if (!state.hasReachedMax) {
                refreshController.loadComplete();
             } else {
                refreshController.loadNoData();
             }
             refreshController.refreshCompleted();
          }
          
          if (state.status == AlertStatus.failure && state.errorMessage.isNotEmpty) {
             showSnackBar("Error", state.errorMessage, Colors.red);
          }
        },
        builder: (context, state) {
          return Scaffold(
              backgroundColor: Colors.white,
              appBar: CommonAppBar(
                elevation: 0,
                title: Text(
                  "Alerts",
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
                    width: size.width * numD04,
                  )
                ],
                hideLeading: false,
              ),
              body: state.status == AlertStatus.loading && state.alerts.isEmpty
                  ? showLoader()
                  : Padding(
                      padding: EdgeInsets.all(size.width * numD03),
                      child: SmartRefresher(
                        controller: refreshController,
                        enablePullDown: true,
                        enablePullUp: true,
                        onRefresh: () {
                           context.read<AlertBloc>().add(RefreshAlertsEvent());
                        },
                        onLoading: () {
                           context.read<AlertBloc>().add(LoadMoreAlertsEvent());
                        },
                        footer: const CustomFooter(builder: commonRefresherFooter),
                        child: state.alerts.isEmpty && state.status == AlertStatus.success
                           ? _buildEmptyState(size) 
                           : ListView.separated(
                          itemCount: state.alerts.length,
                          itemBuilder: (context, index) {
                            var item = state.alerts[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  alignment: Alignment.bottomLeft,
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(size.width * numD03),
                                      child: Image.network(
                                        item.image,
                                        width: double.infinity,
                                        height: size.width * numD50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, s, v) {
                                          return Container(
                                            width: double.infinity,
                                            height: size.width * numD50,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(
                                                    size.width * numD03),
                                                color: colorLightGrey),
                                          );
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: size.width * numD02,
                                          horizontal: size.width * numD045),
                                      margin: EdgeInsets.all(size.width * numD03),
                                      decoration: BoxDecoration(
                                        color: colorThemePink,
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD06),
                                      ),
                                      child: Text(
                                          "Earn $currencySymbol${item.minEarning} - $currencySymbol${item.maxEarning}",
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD035,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: size.width * numD035,
                                ),
                                Text(
                                  item.description.trim().toCapitalized(),
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      lineHeight: 1.5,
                                      fontWeight: FontWeight.normal),
                                ),
                                SizedBox(
                                  height: size.width * numD035,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          /// Time Date
                                          Row(
                                            children: [
                                              Image.asset(
                                                "${iconsPath}ic_yearly_calendar.png",
                                                height: size.width * numD038,
                                                color: Colors.black,
                                              ),
                                              SizedBox(
                                                width: size.width * numD018,
                                              ),
                                              Text(
                                                  dateTimeFormatter(
                                                      dateTime: item.createdAt,
                                                      format: "dd MMM yyyy"),
                                                  style: commonTextStyle(
                                                      size: size,
                                                      fontSize: size.width * numD028,
                                                      color: colorHint,
                                                      fontWeight: FontWeight.normal)),
                                              SizedBox(
                                                width: size.width * numD02,
                                              ),
                                              Image.asset(
                                                "${iconsPath}ic_clock.png",
                                                height: size.width * numD038,
                                                color: Colors.black,
                                              ),
                                              SizedBox(
                                                width: size.width * numD018,
                                              ),
                                              Text(
                                                  dateTimeFormatter(
                                                      dateTime: item.createdAt,
                                                      format: "hh:mm a"),
                                                  style: commonTextStyle(
                                                      size: size,
                                                      fontSize: size.width * numD028,
                                                      color: colorHint,
                                                      fontWeight: FontWeight.normal)),
                                            ],
                                          ),
                                          SizedBox(
                                            height: size.width * numD025,
                                          ),

                                          /// Location
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                "${iconsPath}ic_location.png",
                                                height: size.width * numD04,
                                                color: colorHint,
                                              ),
                                              SizedBox(
                                                width: size.width * numD02,
                                              ),
                                              Expanded(
                                                child: Text(item.location,
                                                    style: commonTextStyle(
                                                        size: size,
                                                        fontSize:
                                                            size.width * numD028,
                                                        color: colorHint,
                                                        fontWeight:
                                                            FontWeight.normal)),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: size.width * numD025,
                                          ),
                                          Row(
                                            children: [
                                              Image.asset(
                                                "${iconsPath}ic_location.png",
                                                height: size.width * numD04,
                                                color: colorHint,
                                              ),
                                              SizedBox(
                                                width: size.width * numD02,
                                              ),
                                              Text(item.miles,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: commonTextStyle(
                                                      size: size,
                                                      fontSize: size.width * numD028,
                                                      color: colorHint,
                                                      fontWeight: FontWeight.normal)),
                                              SizedBox(
                                                width: size.width * numD018,
                                              ),
                                              Container(
                                                width: 1,
                                                height: size.width * numD04,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(
                                                width: size.width * numD02,
                                              ),
                                              Image.asset(
                                                "${iconsPath}ic_man_walking.png",
                                                height: size.width * numD036,
                                              ),
                                              SizedBox(
                                                width: size.width * numD01,
                                              ),
                                              Text(item.byFeet,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: commonTextStyle(
                                                      size: size,
                                                      fontSize: size.width * numD028,
                                                      color: colorHint,
                                                      fontWeight: FontWeight.normal)),
                                              SizedBox(
                                                width: size.width * numD01,
                                              ),
                                              Container(
                                                width: 1,
                                                height: size.width * numD04,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(
                                                width: size.width * numD02,
                                              ),
                                              Image.asset(
                                                "${iconsPath}ic_car.png",
                                                width: size.width * numD038,
                                              ),
                                              SizedBox(
                                                width: size.width * numD01,
                                              ),
                                              Text(item.byCar,
                                                  style: commonTextStyle(
                                                      size: size,
                                                      fontSize: size.width * numD028,
                                                      color: colorHint,
                                                      fontWeight: FontWeight.normal)),
                                            ],
                                          ),
                                          SizedBox(
                                            height: size.width * numD02,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width * numD075,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: size.width * numD07,
                                ),
                                Container(
                                  height: size.width * numD13,
                                  width: double.infinity,
                                  margin: EdgeInsets.only(
                                      left: size.width * numD09,
                                      right: size.width * numD09),
                                  child: commonElevatedButton(
                                      item.isEmergency
                                          ? "Emergency Tips"
                                          : "Let's Go",
                                      size,
                                      commonButtonTextStyle(size),
                                      commonButtonStyle(size, colorThemePink), () {
                                    if (!item.isEmergency) {
                                      openUrl(item.locationData?.coordinates, state.currentLocation);
                                    } else {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => FAQScreen(
                                                  priceTipsSelected: false,
                                                  type: "faq",
                                                  index: 1)));
                                    }
                                  }),
                                )
                              ],
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Container(
                              margin: EdgeInsets.only(
                                  top: size.width * numD05,
                                  bottom: size.width * numD05),
                              child: Divider(
                                thickness: 1,
                                color: Colors.grey.withOpacity(.5),
                              ),
                            );
                          },
                        ),
                      ))
              );
        },
      ),
    );
  }
  
  Widget _buildEmptyState(Size size) {
    return Center(
        child: Text(
          "No alerts found",
          style: commonTextStyle(
              size: size,
              fontSize: size.width * numD04,
              color: Colors.grey,
              fontWeight: FontWeight.w500),
        ),
    );
  }

  Future<void> openUrl(List<double>? coordinates, LatLng? currentLocation) async {
    if (coordinates == null || coordinates.isEmpty || currentLocation == null) {
       if (currentLocation == null) {
         showSnackBar("Location Error", "Current location not found. Please enable location permissions.", Colors.red);
       }
       return;
    }
  
    var lat = coordinates.first;
    var long = coordinates.last;

    debugPrint("lat:::::::$lat::::::long::::::$long");
    String googleUrl = isDirection
        ? 'https://www.google.com/maps/dir/?api=1&origin=${currentLocation.latitude},'
            '${currentLocation.longitude}&destination=$lat,'
            '$long&travelmode=driving&dir_action=navigate'
        : 'https://www.google.com/maps/search/?api=1&query=$lat,$long';

    String appleUrl = isDirection
        ? 'http://maps.apple.com/maps?saddr=${currentLocation.latitude},'
            '${currentLocation.longitude}&daddr=$lat,'
            '$long'
        : 'http://maps.apple.com/?q=$lat,'
            '$long';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      debugPrint('launching com googleUrl');
      await launchUrl(Uri.parse(googleUrl),
          mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(Uri.parse(appleUrl))) {
      debugPrint('launching apple url');
      await launchUrl(Uri.parse(appleUrl),
          mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch url';
    }
  }
}
