import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart' as fic;
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:native_exif/native_exif.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:presshop/main.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/view/cameraScreen/PreviewScreen.dart';
import '../../utils/AnalyticsConstants.dart';
import '../../utils/AnalyticsMixin.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/CommonSharedPrefrence.dart';
import '../dashboard/Dashboard.dart';
import '../permission_error_screen.dart';
import 'CameraScreen.dart';
import 'package:video_player/video_player.dart';

class CustomGallery extends StatefulWidget {
  bool picAgain = false;

  CustomGallery({super.key, required this.picAgain});

  @override
  State<StatefulWidget> createState() {
    return CustomGalleryState();
  }
}

class CustomGalleryState extends State<CustomGallery> with AnalyticsPageMixin {
  List<AssetEntity> _mediaList = [];
  List<CameraData> camListData = [];
  AssetPathEntity? _path;
  String address = "";
  bool isLongPress = false;

  // Analytics Mixin Requirements
  @override
  String get pageName => PageNames.customGallery;

  @override
  Map<String, Object>? get pageParameters => {
        'pic_again': widget.picAgain.toString(),
        'media_count': _mediaList.length.toString(),
      };
  bool isLoading = false;
  bool isSelectedImageProcessing = true;

  String mediaAddress = "", mediaDate = "", country = "", state = "", city = "";

  int totalEntitiesCount = 0;
  double x = 0, y = 0, latitude = 0, longitude = 0;

  final int _sizePerPage = 50;
  int page = 0;
  bool isLoadingMore = false;
  bool hasMoreToLoad = true;
  List<bool> selectedList = [];

  /// Prince
  int selectedIndex = 0;

  @override
  void initState() {
    debugPrint("class::::$runtimeType");
    getMedia();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    bool showDone = selectedList.any((element) => element);
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Dashboard(initialPosition: 2)));

        return false;
      },
      child: Scaffold(
          appBar: CommonAppBar(
            elevation: 0,
            hideLeading: false,
            title: Text(
              galleryText,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: size.width * (isIpad ? numD04 : numD06)),
            ),
            centerTitle: false,
            titleSpacing: 0,
            size: size,
            showActions: showDone,
            leadingFxn: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Dashboard(initialPosition: 2)));
            },
            actionWidget: [
              !isSelectedImageProcessing
                  ? Center(
                      child: Text(
                        "Processing...",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * (isIpad ? numD02 : numD03),
                            color: Colors.grey,
                            fontWeight: FontWeight.w700),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: size.width * (isIpad ? numD004 : numD03)),
                      child: commonElevatedButton(
                          "Done",
                          size,
                          commonTextStyle(
                              size: size,
                              fontSize: size.width * (isIpad ? numD02 : numD03),
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                          commonButtonStyle(size, colorThemePink), () async {
                        /// Prince
                        if (widget.picAgain) {
                          Navigator.pop(context, camListData);
                        } else {
                          var validationVideoLenght = true;
                          for (var item in camListData) {
                            if (item.mimeType == "video") {
                              VideoPlayerController controller =
                                  VideoPlayerController.file(File(item.path));
                              await controller.initialize();
                              if (controller.value.duration.inSeconds >
                                  (sharedPreferences!.getInt(videoLimitKey) ??
                                      120)) {
                                showToast(
                                    "Videos can be up to 2 minutes long — keep it quick, punchy, and straight to the point🎥");
                                validationVideoLenght = false;
                                break;
                              }
                            }
                          }
                          if (validationVideoLenght) {
                            Navigator.push(
                                navigatorKey.currentState!.context,
                                MaterialPageRoute(
                                    builder: (context) => PreviewScreen(
                                          cameraData: null,
                                          pickAgain: widget.picAgain,
                                          type: "gallery",
                                          cameraListData: camListData,
                                          mediaList: [],
                                        )));
                          }
                        }
                      }),
                    ),
              SizedBox(
                width: size.width * numD04,
              )
            ],
          ),
          body: GridView.builder(
              itemCount: _mediaList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
              itemBuilder: (BuildContext context, int index) {
                if (index == _mediaList.length - 20 &&
                    !isLoadingMore &&
                    hasMoreToLoad) {
                  _loadMoreAsset();
                }
                return InkWell(
                  /*    onLongPress: () {
                            if (!selectedList[index]) {
                              selectedList[index] = true;
                              isLongPress = true;

                              /// Prince
                              requestLocationPermissions();
                              _mediaList[index].originFile.then((value) async {
                                debugPrint("Filepath:${value!.absolute.path}");
                                if (_mediaList[index].type == AssetType.video) {
                                  final thumbnail =
                                      await vt.VideoThumbnail.thumbnailFile(
                                    video: value!.absolute.path,
                                    thumbnailPath:
                                        (await getTemporaryDirectory()).path,
                                    imageFormat: vt.ImageFormat.PNG,
                                    maxHeight: 500,
                                    quality: 100,
                                  );
                                  camListData.add(CameraData(
                                    path: value!.absolute.path,
                                    mimeType: "video",
                                    videoImagePath: thumbnail ?? "",
                                    latitude: latitude.toString(),
                                    longitude: longitude.toString(),
                                    dateTime: DateTime.now().toIso8601String(),
                                  ));
                                } else {
                                  camListData.add(CameraData(
                                    path: value!.absolute.path,
                                    mimeType: "image",
                                    videoImagePath: "",
                                    latitude: latitude.toString(),
                                    longitude: longitude.toString(),
                                    dateTime: DateTime.now().toIso8601String(),
                                  ));
                                }
                              });
                              setState(() {});
                            }
                          },*/
                  onTap: () {
                    setState(() {
                      isSelectedImageProcessing = false;
                    });
                    debugPrint("camListData::::${camListData.length}");
                    selectedList[index] = !selectedList[index];
                    if (selectedList[index] == true) {
                      selectedIndex = index;
                      _mediaList[index].originFile.then((value) async {
                        String imgPath = value!.absolute.path;
                        debugPrint("Filepath:::::::> $imgPath");
                        if (_mediaList[index].type == AssetType.video) {
                          final thumbnail =
                              await vt.VideoThumbnail.thumbnailFile(
                            video: imgPath,
                            thumbnailPath: (await getTemporaryDirectory()).path,
                            imageFormat: vt.ImageFormat.PNG,
                            maxHeight: 500,
                            quality: 100,
                          );
                          if (selectedList[index] == true) {
                            camListData.add(CameraData(
                              path: imgPath,
                              mimeType: "video",
                              videoImagePath: thumbnail ?? "",
                              latitude: sharedPreferences!
                                      .getDouble(currentLat)
                                      .toString() ??
                                  "",
                              longitude: sharedPreferences!
                                      .getDouble(currentLon)
                                      .toString() ??
                                  "",
                              dateTime: DateFormat("HH:mm, dd MMM yyyy")
                                  .format(DateTime.now()),
                              location: sharedPreferences!
                                      .getString(currentAddress) ??
                                  "",
                              country: sharedPreferences!
                                      .getString(currentCountry) ??
                                  "",
                              city: sharedPreferences!.getString(currentCity) ??
                                  "",
                              state:
                                  sharedPreferences!.getString(currentState) ??
                                      "",
                            ));
                            setState(() {
                              isSelectedImageProcessing = true;
                            });
                          }
                        } else {
                          try {
                            var exif = await Exif.fromPath(imgPath);
                            final latLong = await exif.getLatLong();

                            final latitude = latLong?.latitude ??
                                sharedPreferences!.getDouble(currentLat)!;
                            final longitude = latLong?.longitude ??
                                sharedPreferences!.getDouble(currentLon)!;

                            // 🔹 Use geocoding to get address info
                            List<Placemark> placemarks =
                                await placemarkFromCoordinates(
                                    latitude, longitude);
                            final place = placemarks.first;

                            camListData.add(CameraData(
                              path: imgPath,
                              mimeType: "image",
                              videoImagePath: "",
                              fromGallary: true,
                              latitude: latitude.toString(),
                              longitude: longitude.toString(),
                              dateTime: DateFormat("HH:mm, dd MMM yyyy")
                                  .format(DateTime.now()),
                              location:
                                  "${place.street}, ${place.locality}, ${place.country}",
                              country: place.country ?? "",
                              city: place.locality ?? "",
                              state: place.administrativeArea ?? "",
                            ));

                            setState(() {
                              isSelectedImageProcessing = true;
                            });
                          } catch (e) {
                            debugPrint("Exif Error: $e");
                          }

                          // camListData.add(CameraData(
                          //   path: imgPath,
                          //   mimeType: "image",
                          //   videoImagePath: "",
                          //   fromGallary: true,
                          //   latitude: data?.latitude.toString() ??
                          //       sharedPreferences!
                          //           .getDouble(currentLat)
                          //           .toString(),
                          //   longitude: data?.longitude.toString() ??
                          //       sharedPreferences!
                          //           .getDouble(currentLon)
                          //           .toString(),
                          //   dateTime: DateFormat("HH:mm, dd MMM yyyy")
                          //       .format(DateTime.now()),
                          //   location: data?.address ?? "",
                          //   country: data?.country ?? "",
                          //   city: data?.city ?? "",
                          //   state: data?.state ?? "",
                          // ));
                          // setState(() {
                          //   isSelectedImageProcessing = true;
                          // });
                        }
                      });
                    } else {
                      _mediaList[index].originFile.then((value) async {
                        String imgPath = value!.absolute.path;
                        int indexing = camListData.indexWhere(
                            (cameraData) => cameraData.path == imgPath);

                        debugPrint("Filepath:::::::> $index  $indexing");
                        camListData.removeAt(indexing);
                        setState(() {
                          isSelectedImageProcessing = true;
                        });
                      });
                    }
                    //  }
                  },
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                          child: Image(
                        image: AssetEntityImageProvider(
                          _mediaList[index],
                          isOriginal: false,
                          thumbnailSize: const ThumbnailSize.square(200),
                          thumbnailFormat: ThumbnailFormat.jpeg,
                        ),
                        fit: BoxFit.cover,
                      )),
                      if (_mediaList[index].type == AssetType.video)
                        const Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 5, bottom: 5),
                            child: Icon(
                              Icons.videocam,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      selectedList[index]
                          ? Positioned.fill(
                              child: Container(
                                  alignment: Alignment.topRight,
                                  decoration: BoxDecoration(
                                      color: colorThemePink.withOpacity(0.5)),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.all(size.width * numD01),
                                    child: Icon(
                                      Icons.radio_button_checked,
                                      color: Colors.black,
                                      size: size.width * numD05,
                                    ),
                                  )),
                            )
                          : Container()
                    ],
                  ),
                );
              })),
    );
  }

  Future<void> getMedia() async {
    final PermissionState result = await PhotoManager.requestPermissionExtend();
    if (result.hasAccess) {
      List<AssetPathEntity> paths =
          await PhotoManager.getAssetPathList(onlyAll: true);
      debugPrint("all Path values====>  $paths");

      if (paths.isNotEmpty) {
        setState(() {
          _path = paths.first;
        });

        totalEntitiesCount = await _path!.assetCountAsync;
        List<AssetEntity> media =
            await _path!.getAssetListPaged(page: page, size: _sizePerPage);
        _mediaList = media;

        debugPrint("MyMedia: $media");
        hasMoreToLoad = media.length < totalEntitiesCount;
      }
      selectedList = List.filled(_mediaList.length, false);

      debugPrint("SelectedList: ${selectedList.first}");
      debugPrint("SelectedList: ${selectedList.length}");
      debugPrint("_mediaList.length: ${_mediaList.length}");
      isLoading = true;
      setState(() {});
      if (!mounted) {
        return;
      }
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => PermissionErrorScreen(permissionsStatus: {
                    Permission.photos: false,
                  })));
    }
  }

  Future<void> _loadMoreAsset() async {
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: page + 1,
      size: _sizePerPage,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _mediaList.addAll(entities);
      if (entities.isNotEmpty) {
        selectedList = List.filled(_mediaList.length, false);
      }
      page++;
      hasMoreToLoad = _mediaList.length < totalEntitiesCount;
      isLoadingMore = false;
    });
  }

  Future<String> convertHEICToJPEG(String path, int width, int height) async {
    try {
      // Generate a new file path for the JPEG
      final dir = await getTemporaryDirectory();
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final newPath = "${dir.path}/$fileName";

      // Convert HEIC to JPEG and save to newPath
      var result = await fic.FlutterImageCompress.compressAndGetFile(
        path,
        newPath,
        quality: 95,
        format: fic.CompressFormat.jpeg,
      );

      if (result != null) {
        return result.path;
      } else {
        debugPrint('Conversion failed, result is null');
        return "";
      }
    } catch (error) {
      debugPrint('Error converting HEIC to JPEG: $error');
      return "";
    }
  }

/* /// Location permission request
  requestLocationPermissions() async {
    lc.PermissionStatus permissionGranted;
    bool serviceEnabled;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }

    if (serviceEnabled) {
      permissionGranted = await location.hasPermission();

      debugPrint("PG: $permissionGranted");

      switch (permissionGranted) {
        case lc.PermissionStatus.granted:
          getCurrentLocationFxn();
          break;
        case lc.PermissionStatus.grantedLimited:
          showSnackBar("Error", "Permission is limited", Colors.red);

          break;
        case lc.PermissionStatus.denied:
          serviceEnabled = await location.requestService().then((value) {
            getCurrentLocationFxn();
            return true;
          });
          break;
        case lc.PermissionStatus.deniedForever:
          openAppSettings().then((value) {
            if (value) {
              getCurrentLocationFxn();
            }
          });
          break;
      }
    }
  }

  getCurrentLocationFxn() async {
    try {
      locationData = await location.getLocation();
      debugPrint("GettingLocation ==> $locationData");
      if (locationData != null) {
        debugPrint("NotNull");
        if (locationData!.latitude != null) {
          latitude = locationData!.latitude!;
          longitude = locationData!.longitude!;

          List<Placemark> placeMarkList =
              await placemarkFromCoordinates(latitude, longitude);

          debugPrint("PlaceHolder: ${placeMarkList.first}");

          String street = placeMarkList.first.name!;
          String nagar = placeMarkList.first.subLocality!;
          String cityValue = placeMarkList.first.locality!;
          String stateValue = placeMarkList.first.administrativeArea!;
          String countryValue = placeMarkList.first.country!;
          String pinCode = placeMarkList.first.postalCode!;

          mediaAddress = "$nagar, $street, $pinCode";
          country = countryValue;
          state = stateValue;
          city = cityValue;

          debugPrint("MyLatttt: ${locationData!.latitude}");
          debugPrint("MyLonggggg: ${locationData!.longitude}");
          debugPrint("mediaAddress: $mediaAddress");
          isLoading = false;
          setState(() {});
          if (alertDialog != null) {
            alertDialog = null;
            Navigator.of(navigatorKey.currentContext!).pop();
          }
        }
      } else {
        debugPrint("Null-ll");

        showSnackBar("Location Error", "nullLocationText", Colors.black);
      }
    } on Exception catch (e) {
      debugPrint("PEx: $e");

      showSnackBar("Exception", e.toString(), Colors.black);
    }
  }*/
}

class GalleryModel {
  Uint8List? thumbPath;
  AssetEntity? assetData;

  GalleryModel({required this.thumbPath, required this.assetData});
}
