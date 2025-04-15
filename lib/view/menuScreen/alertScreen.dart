import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/menuScreen/FAQScreen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/Common.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/CommonWigdets.dart';
import '../../utils/PermissionHandler.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../dashboard/Dashboard.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> implements NetworkResponse {
  List<AlertModel> alertList = [];
  bool isLoading = false;
  bool isDirection = false;
  int offset = 0;
  RefreshController refreshController = RefreshController(initialRefresh: false);
  LatLng? latLng;

  @override
  void initState() {
    getCurrentLocation();
    callGetAlertListApi();
    super.initState();
  }
  void onRefresh() async {
   alertList.clear();
    offset = 0;
    await Future.delayed(const Duration(milliseconds: 1000), () {
callGetAlertListApi();
    });
    refreshController.refreshCompleted();
  }

  void onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000), () {
      offset += 10;
      callGetAlertListApi();
    });
   setState(() {});
    refreshController.loadComplete();
  }



  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
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
      body: isLoading
          ? Padding(
              padding: EdgeInsets.all(size.width * numD03),
              child: SmartRefresher(
                controller: refreshController,
                enablePullDown: true,
                enablePullUp: true,
                onRefresh: onRefresh,
                onLoading: onLoading,
                footer:
                const CustomFooter(builder: commonRefresherFooter),
                child: ListView.separated(
                  itemCount: alertList.length,
                  itemBuilder: (context, index) {
                    var item = alertList[index];
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
                                errorBuilder: (c,s,v){
                                  return Container(
                                    width: double.infinity,
                                    height: size.width * numD50,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(size.width * numD03),
                                      color: colorLightGrey
                                    ),
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
                                borderRadius:
                                    BorderRadius.circular(size.width * numD06),
                              ),
                              child: Text("Earn £${item.minEarning} - £${item.maxEarning}",
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
                          item.description.trim(),
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
                                            fontWeight: FontWeight.normal)
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.width * numD025,
                                  ),

                                  /// Location
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                        child: Text(
                                          item.location,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD028,
                                                color: colorHint,
                                                fontWeight: FontWeight.normal)
                                        ),
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
                                      Text(
                                        item.miles,
                                        overflow: TextOverflow.ellipsis,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD028,
                                              color: colorHint,
                                              fontWeight: FontWeight.normal)
                                      ),
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
                                      Text(
                                        item.byFeet,
                                        overflow: TextOverflow.ellipsis,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD028,
                                              color: colorHint,
                                              fontWeight: FontWeight.normal)
                                      ),
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
                                      Text(
                                        item.byCar,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD028,
                                              color: colorHint,
                                              fontWeight: FontWeight.normal)
                                      ),
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
                             item.isEmergency? "Emergency Tips":"Let's Go",
                              size,
                              commonButtonTextStyle(size),
                              commonButtonStyle(size, colorThemePink),
                              () {
                               if(!item.isEmergency){
                                 openUrl(item.locationData!.coordinates);
                               }else{
                                 Navigator.push(context, MaterialPageRoute(builder: (context)=>FAQScreen(priceTipsSelected: false, type: "faq",index:1)));
                               }


                              }),
                        )
                      ],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: EdgeInsets.only(
                          top: size.width * numD05, bottom: size.width * numD05),
                      child:Divider(
                        thickness: 1,
                        color: Colors.grey.withOpacity(.5),
                      ),
                    );
                  },
                ),
              ))
          : showLoader()
    );
  }

  void getCurrentLocation() async {
    bool serviceEnable = await checkGps();
    bool locationEnable = await locationPermission();
    if (serviceEnable && locationEnable) {
      LocationData loc = await Location.instance.getLocation();
      setState(() {
        latLng = LatLng(loc.latitude!, loc.longitude!);
        debugPrint("_longitude: $latLng");
      });
    } else {
      showSnackBar(
          "Permission Denied", "Please Allow Location permission", Colors.red);
    }
  }
  

  openUrl(List<double>? coordinates) async {
    var lat = coordinates!.first ;
    var long=  coordinates.last;

    debugPrint("lat:::::::$lat::::::long::::::$long");
    String googleUrl = isDirection
        ? 'https://www.google.com/maps/dir/?api=1&origin=${latLng!.latitude},'
        '$long&destination=$lat,'
        '$long&travelmode=driving&dir_action=navigate'
        : 'https://www.google.com/maps/search/?api=1&query=$lat,$long';


    String appleUrl = isDirection
        ? 'http://maps.apple.com/maps?saddr=${latLng!.latitude},'
        '${latLng!.longitude}&daddr=$lat,'
        '$long'
        : 'http://maps.apple.com/?q=$lat,'
        '$long';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      debugPrint('launching com googleUrl');
      await launchUrl(Uri.parse(googleUrl),
          mode: LaunchMode.externalApplication);
    }
    else if (await canLaunchUrl(Uri.parse(appleUrl))) {
      debugPrint('launching apple url');
      await launchUrl(Uri.parse(appleUrl),
          mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch url';
    }

  }

  callGetAlertListApi() {
    NetworkClass("${allAlertUrl}limit=10&offset=$offset", this, allAlertReq)
        .callRequestServiceHeader(false, 'get', null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case allAlertReq:
          log("callGetAllAlertReq error:::::$response");
          break;
      }
    } on Exception catch (e) {
      debugPrint('exception catch====> $e');
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case allAlertReq:
          log("callGetAllAlertReq success:::::$response");
          var data = jsonDecode(response);
          var dataModel = data['data'] as List;
          var aList = dataModel.map((e) => AlertModel.fromJson(e)).toList();
          if (offset == 0) {
            alertList.clear();
          }
          if (aList.isNotEmpty) {
            refreshController.loadComplete();
          } else if (aList.isEmpty) {
            refreshController.loadNoData();
          } else {
            refreshController.loadFailed();
          }
          alertList.addAll(aList);
          debugPrint("alertList length::::: ${alertList.length}");
          isLoading = true;
          setState(() {});
          break;
      }
    } on Exception catch (e) {
      debugPrint('exception catch====> $e');
    }
  }
}

class AlertModel {
  String id = "";
  String description = "";
  String location = "";
  String image = "";
  String distance = "";
  String createdAt = "";
  String miles = "";
  String byFeet = "";
  String byCar= "";
  bool isEmergency= false;
  String minEarning= "";
  String maxEarning= "";
  LocationModel?locationData;


  AlertModel({
    required this.id,
    required this.description,
    required this.location,
    required this.image,
    required this.distance,
    required this.createdAt,
    required this.miles,
    required this.byFeet,
    required this.byCar,
    required this.isEmergency,
    required this.minEarning,
    required this.maxEarning,
    required this.locationData,
  });



  factory AlertModel.fromJson(Map<String, dynamic> json) {
    double dis =0.0;
    String miles ="";
    String byFeet ="";
    String byCar ="";
    calculateTravelDetails(double distanceInMeters) {
      double distanceInMiles = distanceInMeters / 1609.34;
      double distanceInFeet = distanceInMeters * 3.28084;
      double averageSpeedKmh = 60.0;
      double averageSpeedFeetPerMinute = (averageSpeedKmh * 1000 * 3.28084) / 60.0;
      double timeByCarInMinutes = (distanceInMeters / 1000) / averageSpeedKmh * 60;
      double timeByFeetInMinutes = distanceInFeet / averageSpeedFeetPerMinute;
      String formattedTime;
      String formattedCarTime;
      if (timeByFeetInMinutes >= 60) {
        int hours = timeByFeetInMinutes ~/ 60;
        int hour = timeByCarInMinutes ~/ 60;
        double minutes = timeByFeetInMinutes.round() % 60;
        double minute = timeByCarInMinutes.round() % 60;
        formattedTime = "$hours h ";
        formattedCarTime = "$hour h";
      } else {
        formattedTime = "${timeByFeetInMinutes.round().toString()} min";
        formattedCarTime = "${timeByCarInMinutes.round().toString()} min";
      }
       miles = "${distanceInMiles.round().toString()} mi";
       byFeet =formattedTime.toString();
       byCar =formattedCarTime.toString();

      debugPrint("Distance in Miles: ${distanceInMiles.toStringAsFixed(2)} miles");
      debugPrint("Estimated Travel Time by Car (using meters): $formattedCarTime minutes");
      debugPrint("Total Time Taken (using feet): $formattedTime to cover the distance in feet");
    }
    if(json['distance'].toString().isNotEmpty){
       dis = json['distance'];
       calculateTravelDetails(dis);
    }
    return AlertModel(
      id: json['_id'] ?? "",
      description: json['title'] ?? "",
      location: json['address'] ?? "",
      image: json['image'] ?? "",
      distance: dis.toString(),
      createdAt: json['createdAt'] ?? "",
      miles: miles,
      byFeet: byFeet,
      byCar: byCar,
      isEmergency: json['is_emergency']??false,
      minEarning: json['min_earning'].toString(),
      maxEarning: json['max_earning'].toString(),
      locationData: json['location']!=null?LocationModel.fromJson(json['location']):LocationModel()

    );

  }
}

class LocationModel {
  String? type;
  List<double>? coordinates;

  LocationModel({
    this.type,
    this.coordinates,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      type: json['type'] ?? '',
      coordinates: (json['coordinates'] != null)
          ? json['coordinates'].cast<double>()
          : [],
    );
  }
}
