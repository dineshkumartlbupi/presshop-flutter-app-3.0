import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart' as fic;
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:presshop/core/di/injection_container.dart' as di;
import 'package:go_router/go_router.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/camera/data/models/camera_model.dart';
import 'package:video_player/video_player.dart';
import 'package:presshop/main.dart';
import 'package:exif/exif.dart' as exif_lib;

// ignore: must_be_immutable
class CustomGallery extends StatefulWidget {
  CustomGallery({super.key, required this.picAgain});
  bool picAgain = false;

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
  bool _isLimited = false;

  String mediaAddress = "", mediaDate = "", country = "", state = "", city = "";

  int totalEntitiesCount = 0;
  double x = 0, y = 0, latitude = 0, longitude = 0;

  double _convertRatioToDouble(dynamic ratio) {
    try {
      if (ratio is List && ratio.length >= 3) {
        double d = ratio[0].numerator /
            (ratio[0].denominator == 0 ? 1 : ratio[0].denominator);
        double m = ratio[1].numerator /
            (ratio[1].denominator == 0 ? 1 : ratio[1].denominator);
        double s = ratio[2].numerator /
            (ratio[2].denominator == 0 ? 1 : ratio[2].denominator);
        double result = d + (m / 60.0) + (s / 3600.0);
        if (result.isNaN || result.isInfinite) return 0.0;
        return result;
      }
    } catch (e) {
      debugPrint("pure_exif convert error: $e");
    }
    return 0.0;
  }

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
    PhotoManager.addChangeCallback(_handleMediaChange);
    PhotoManager.startChangeNotify();
    getMedia();
    super.initState();
  }

  @override
  void dispose() {
    PhotoManager.removeChangeCallback(_handleMediaChange);
    PhotoManager.stopChangeNotify();
    super.dispose();
  }

  void _handleMediaChange(MethodCall call) {
    debugPrint("🚀 CustomGallery: Media changed, refreshing...");
    getMedia();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    bool showDone = selectedList.any((element) => element);
    return WillPopScope(
      onWillPop: () async {
        context.pop();

        return false;
      },
      child: Scaffold(
          appBar: CommonBrandedAppBar(
            title: AppStrings.galleryText,
            size: size,
            showLogo: false,
            actionWidgets: [
              if (_isLimited)
                IconButton(
                  onPressed: () async {
                    // This opens the system picker to add/remove photos from limited access
                    await PhotoManager.presentLimited();
                    
                    // Small delay to let native side update its cache
                    await Future.delayed(const Duration(milliseconds: 500));
                    
                    // Explicitly refresh the media list
                    getMedia();
                  },
                  icon: Icon(Icons.add_photo_alternate_outlined,
                      color: AppColorTheme.colorThemePink),
                  tooltip: "Select More Photos",
                ),
              if (showDone)
                !isSelectedImageProcessing
                    ? Center(
                        child: Text(
                          "Processing...",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width *
                                  (isIpad
                                      ? AppDimensions.numD02
                                      : AppDimensions.numD03),
                              color: Colors.grey,
                              fontWeight: FontWeight.w700),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width *
                                (isIpad
                                    ? AppDimensions.numD004
                                    : AppDimensions.numD040),
                            vertical: size.width *
                                (isIpad
                                    ? AppDimensions.numD002
                                    : AppDimensions.numD01)),
                        child: commonElevatedButton(
                            "Done",
                            size,
                            commonTextStyle(
                                size: size,
                                fontSize: size.width *
                                    (isIpad
                                        ? AppDimensions.numD02
                                        : AppDimensions.numD03),
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                            commonButtonStyle(
                                size, AppColorTheme.colorThemePink), () async {
                          /// Prince
                          if (widget.picAgain) {
                            context.pop(camListData);
                          } else {
                            var validationVideoLenght = true;
                            for (var item in camListData) {
                              if (item.mimeType == "video") {
                                VideoPlayerController controller =
                                    VideoPlayerController.file(File(item.path));
                                try {
                                  await controller.initialize();
                                  if (controller.value.duration.inSeconds >
                                      (sharedPreferences?.getInt(
                                              SharedPreferencesKeys
                                                  .videoLimitKey) ??
                                          120)) {
                                    showToast(
                                        "Videos can be up to 2 minutes long — keep it quick, punchy, and straight to the point🎥");
                                    validationVideoLenght = false;
                                    break;
                                  }
                                } finally {
                                  await controller.dispose();
                                }
                              }
                            }
                            if (validationVideoLenght) {
                              context.pushNamed(AppRoutes.previewName, extra: {
                                'cameraData': null,
                                'pickAgain': widget.picAgain,
                                'type': "gallery",
                                'cameraListData': camListData,
                                'mediaList': [],
                              });
                            }
                          }
                        }),
                      ),
            ],
          ),
          body: !isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColorTheme.colorThemePink,
                  ),
                )
              : _mediaList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library_outlined,
                              size: size.width * 0.15, color: Colors.grey),
                          SizedBox(height: size.width * 0.04),
                          Text(
                            "No images or videos found",
                            style: commonTextStyle(
                              size: size,
                              fontSize: size.width * 0.04,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_isLimited) ...[
                            SizedBox(height: size.width * 0.06),
                            commonElevatedButton(
                              "Select Photos from Gallery",
                              size,
                              commonTextStyle(
                                size: size,
                                fontSize: size.width * 0.035,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              commonButtonStyle(
                                  size, AppColorTheme.colorThemePink),
                              () async {
                                await PhotoManager.presentLimited();
                                await Future.delayed(
                                    const Duration(milliseconds: 500));
                                getMedia();
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.1,
                                  vertical: size.width * 0.04),
                              child: Text(
                                "You have given limited access to your gallery. Tap above to select more photos.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: size.width * 0.03,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : GridView.builder(
                      itemCount: _mediaList.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5),
                      itemBuilder: (context, index) {
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
                                    thumbnailPath:
                                        (await getTemporaryDirectory()).path,
                                    imageFormat: vt.ImageFormat.PNG,
                                    maxHeight: 500,
                                    quality: 100,
                                  );
                                  if (selectedList[index] == true) {
                                    double? latitude =
                                        _mediaList[index].latitude;
                                    double? longitude =
                                        _mediaList[index].longitude;
                                    String location = "";
                                    String city = "";
                                    String state = "";
                                    String country = "";

                                    if (latitude != null &&
                                        longitude != null &&
                                        latitude != 0.0 &&
                                        longitude != 0.0) {
                                      try {
                                        List<Placemark> placemarks =
                                            await placemarkFromCoordinates(
                                                latitude, longitude);
                                        final place = placemarks.first;
                                        location =
                                            "${place.street}, ${place.locality}, ${place.country}";
                                        city = place.locality ?? "";
                                        state = place.administrativeArea ?? "";
                                        country = place.country ?? "";
                                      } catch (e) {
                                        debugPrint(
                                            "Geocoding error for video: $e");
                                      }
                                    }

                                    camListData.add(CameraData(
                                      path: imgPath,
                                      mimeType: "video",
                                      videoImagePath: thumbnail ?? "",
                                      latitude: latitude != 0.0
                                          ? latitude.toString()
                                          : "",
                                      longitude: longitude != 0.0
                                          ? longitude.toString()
                                          : "",
                                      dateTime: DateFormat("HH:mm, dd MMM yyyy")
                                          .format(DateTime.now()),
                                      location: location,
                                      country: country,
                                      city: city,
                                      state: state,
                                    ));
                                    setState(() {
                                      isSelectedImageProcessing = true;
                                    });
                                  }
                                } else {
                                  try {
                                    final bytes =
                                        await File(imgPath).readAsBytes();
                                    final tags =
                                        await exif_lib.readExifFromBytes(bytes);

                                    double? latitude;
                                    double? longitude;

                                    if (tags.containsKey('GPS GPSLatitude') &&
                                        tags.containsKey('GPS GPSLongitude')) {
                                      latitude = _convertTagToDouble(
                                          tags['GPS GPSLatitude']);
                                      longitude = _convertTagToDouble(
                                          tags['GPS GPSLongitude']);

                                      // Handle North/South East/West ref
                                      if (tags['GPS GPSLatitudeRef']
                                                  ?.printable ==
                                              'S' &&
                                          latitude != null) {
                                        latitude = -latitude;
                                      }
                                      if (tags['GPS GPSLongitudeRef']
                                                  ?.printable ==
                                              'W' &&
                                          longitude != null) {
                                        longitude = -longitude;
                                      }
                                    }

                                    // 🔹 Fallback to photo_manager's location data
                                    if (latitude == null || longitude == null) {
                                      latitude = _mediaList[index].latitude;
                                      longitude = _mediaList[index].longitude;
                                    }

                                    if (latitude != null &&
                                        longitude != null &&
                                        latitude != 0.0 &&
                                        longitude != 0.0) {
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
                                        dateTime:
                                            DateFormat("HH:mm, dd MMM yyyy")
                                                .format(DateTime.now()),
                                        location:
                                            "${place.street}, ${place.locality}, ${place.country}",
                                        country: place.country ?? "",
                                        city: place.locality ?? "",
                                        state: place.administrativeArea ?? "",
                                      ));
                                    } else {
                                      camListData.add(CameraData(
                                        path: imgPath,
                                        mimeType: "image",
                                        videoImagePath: "",
                                        fromGallary: true,
                                        latitude: "",
                                        longitude: "",
                                        dateTime:
                                            DateFormat("HH:mm, dd MMM yyyy")
                                                .format(DateTime.now()),
                                        location: "",
                                        country: "",
                                        city: "",
                                        state: "",
                                      ));
                                    }

                                    setState(() {
                                      isSelectedImageProcessing = true;
                                    });
                                  } catch (e) {
                                    debugPrint("Exif Error: $e");
                                  }
                                }
                              });
                            } else {
                              _mediaList[index].originFile.then((value) async {
                                String imgPath = value!.absolute.path;
                                int indexing = camListData.indexWhere(
                                    (cameraData) => cameraData.path == imgPath);

                                debugPrint(
                                    "Filepath:::::::> $index  $indexing");
                                if (indexing != -1 &&
                                    indexing < camListData.length) {
                                  camListData.removeAt(indexing);
                                }
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
                                  thumbnailSize:
                                      const ThumbnailSize.square(200),
                                  thumbnailFormat: ThumbnailFormat.jpeg,
                                ),
                                fit: BoxFit.cover,
                              )),
                              if (_mediaList[index].type == AssetType.video)
                                const Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(right: 5, bottom: 5),
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
                                              color: AppColorTheme
                                                  .colorThemePink
                                                  .withOpacity(0.5)),
                                          child: Padding(
                                            padding: EdgeInsets.all(size.width *
                                                AppDimensions.numD01),
                                            child: Icon(
                                              Icons.radio_button_checked,
                                              color: Colors.black,
                                              size: size.width *
                                                  AppDimensions.numD05,
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
    setState(() {
      isLoading = false;
    });
    final LocationService locationService = di.sl<LocationService>();
    Permission permission = Permission.photos;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt < 33) {
        permission = Permission.storage;
      } else {
        await locationService.requestPermission(Permission.accessMediaLocation);
      }
    }

    // Standard permission check via service
    final bool hasAccess = await locationService.requestPermission(permission);
    if (!hasAccess) {
      if (!mounted) return;
      context.pushReplacementNamed(
        AppRoutes.permissionErrorName,
        extra: {
          'permissionsStatus': {permission: false},
        },
      );
      return;
    }

    final PermissionState state = await PhotoManager.requestPermissionExtend();
    _isLimited = state == PermissionState.limited;

    // 🔥 Use proper filter options
    final filter = FilterOptionGroup(
      imageOption: const FilterOption(),
      videoOption: const FilterOption(
        durationConstraint: DurationConstraint(
          max: Duration(seconds: 600),
        ),
      ),
      orders: [
        const OrderOption(
          type: OrderOptionType.createDate,
          asc: false, // latest first
        ),
      ],
    );

    List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      type: RequestType.all,
      onlyAll: _isLimited,
      filterOption: filter,
    );

    if (paths.isEmpty) {
      setState(() {
        _mediaList = [];
        selectedList = [];
        isLoading = true;
      });
      return;
    }

    // Try to find the best album
    AssetPathEntity? bestPath;
    if (_isLimited) {
      bestPath = paths.first;
    } else {
      for (var p in paths) {
        if (p.isAll ||
            p.name.toLowerCase() == "recent" ||
            p.name.toLowerCase() == "all") {
          bestPath = p;
          break;
        }
      }
    }
    _path = bestPath ?? paths.first;

    totalEntitiesCount = await _path!.assetCountAsync;

    // If the selected album is empty and not limited, try to find ANY album with assets
    if (totalEntitiesCount == 0 && !_isLimited) {
      for (var p in paths) {
        if (p == _path) continue;
        int count = await p.assetCountAsync;
        if (count > 0) {
          _path = p;
          totalEntitiesCount = count;
          break;
        }
      }
    }

    List<AssetEntity> media =
        await _path!.getAssetListPaged(page: 0, size: _sizePerPage);

    setState(() {
      page = 0;
      _mediaList = media;
      selectedList = List.filled(media.length, false);
      hasMoreToLoad = _mediaList.length < totalEntitiesCount;
      isLoading = true;
    });
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

  double? _convertTagToDouble(exif_lib.IfdTag? tag) {
    if (tag == null || tag.values is! List || (tag.values as List).length < 3) {
      return null;
    }
    final values = tag.values as List;

    double d = _toDouble(values[0]);
    double m = _toDouble(values[1]);
    double s = _toDouble(values[2]);

    return d + (m / 60.0) + (s / 3600.0);
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    try {
      return value.toDouble();
    } catch (e) {
      return 0.0;
    }
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
            context.pop();
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
  GalleryModel({required this.thumbPath, required this.assetData});
  Uint8List? thumbPath;
  AssetEntity? assetData;
}
