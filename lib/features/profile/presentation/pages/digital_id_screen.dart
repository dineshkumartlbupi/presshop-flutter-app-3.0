import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';

import 'package:presshop/main.dart';
import 'package:presshop/core/core_export.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/bloc/profile_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/bloc/profile_event.dart';
import '../../presentation/bloc/profile_state.dart';
import 'package:presshop/core/di/injection_container.dart';
import '../../domain/entities/profile_data.dart';

class DigitalIdScreen extends StatefulWidget {
  const DigitalIdScreen({super.key});

  @override
  State<DigitalIdScreen> createState() => _DigitalIdScreenState();
}

class _DigitalIdScreenState extends State<DigitalIdScreen> {
  late Size size;
  String userImage = "";
  String userName = "";
  String fullName = "";

  // File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    String firstName =
        sharedPreferences!.getString(SharedPreferencesKeys.firstNameKey) ??
            "Hopper";
    String lastName =
        sharedPreferences!.getString(SharedPreferencesKeys.lastNameKey) ?? "";
    fullName = firstName + (lastName.isNotEmpty ? " $lastName" : "");
    userName =
        sharedPreferences!.getString(SharedPreferencesKeys.userNameKey) ??
            "Hopper";
    // Setup initial image from prefs if available
    String sessionAvatar =
        sharedPreferences!.getString(SharedPreferencesKeys.profileImageKey) ??
            "";
    if (sessionAvatar.isNotEmpty) {
      userImage = sessionAvatar;
    }
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (modalContext) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery, context);
                  modalContext.pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera, context);
                  modalContext.pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        if (!mounted) return;
        context
            .read<ProfileBloc>()
            .add(UploadProfileImageEvent(pickedFile.path));
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return BlocProvider.value(
      value: sl<ProfileBloc>()..add(const FetchProfileEvent(showLoader: false)),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _updateUserProfile(state.profile);
          } else if (state is ProfileImageUploaded) {
            _updateUserImage(state.imageUrl);
          } else if (state is ProfileUpdated) {
            _updateUserProfile(state.profile);
            showSnackBar(
                "Success", "Profile updated successfully", Colors.green);
          } else if (state is ProfileError) {
            Fluttertoast.showToast(msg: state.message);
          }
        },
        builder: (context, state) {
          bool isLoading = state is ProfileLoading;

          return Scaffold(
            // appBar: CommonBrandedAppBar(
            //   title: AppStrings.digitalId,
            //   size: size,
            // ),
            appBar: CommonAppBar(
              elevation: 0,
              hideLeading: false,
              title: Text(
                AppStrings.digitalId,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: size.width * AppDimensions.appBarHeadingFontSize,
                    fontWeight: FontWeight.w700),
              ),
              centerTitle: false,
              titleSpacing: 0,
              size: size,
              showActions: true,
              leadingFxn: () {
                context.pop();
              },
              actionWidget: [
                InkWell(
                  onTap: () {
                    context.goNamed(AppRoutes.dashboardName,
                        extra: {'initialPosition': 2});
                  },
                  child: Image.asset(
                    "${commonImagePath}rabbitLogo.png",
                    height: size.width * AppDimensions.numD07,
                    width: size.width * AppDimensions.numD07,
                  ),
                ),
                SizedBox(
                  width: size.width * AppDimensions.numD04,
                )
              ],
            ),
            body: Container(
              margin: EdgeInsets.only(
                left: size.width * AppDimensions.numD04,
                right: size.width * AppDimensions.numD04,
                top: size.width * AppDimensions.numD02,
                bottom: size.width * AppDimensions.numD1,
              ),
              decoration: BoxDecoration(
                  color: AppColorTheme.colorLightGrey,
                  borderRadius:
                      BorderRadius.circular(size.width * AppDimensions.numD03),
                  border: Border.all(width: 1.0, color: Colors.black)),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: EdgeInsets.only(
                        left: size.width * AppDimensions.numD03,
                        right: size.width * AppDimensions.numD28,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          //mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: size.width * AppDimensions.numD03,
                            ),

                            /// Rabbit logo
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Image.asset(
                                  "${commonImagePath}rabbitLogo.png",
                                  height: size.width * AppDimensions.numD28,
                                  // width: size.width * AppDimensions.numD1,
                                ),
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "press",
                                          style: TextStyle(
                                              fontSize: size.width *
                                                  AppDimensions.numD065,
                                              color: Colors.black,
                                              fontFamily: "AirbnbCereal",
                                              fontWeight: FontWeight.normal),
                                        ),
                                        Text(
                                          "hop",
                                          style: TextStyle(
                                              fontSize: size.width *
                                                  AppDimensions.numD065,
                                              color: Colors.black,
                                              letterSpacing: 0,
                                              fontFamily: "AirbnbCereal",
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "news delivered",
                                      style: TextStyle(
                                          fontSize:
                                              size.width * AppDimensions.numD04,
                                          color: Colors.black,
                                          fontFamily: "AirbnbCereal",
                                          fontWeight: FontWeight.normal),
                                    ),
                                    SizedBox(height: 8)
                                  ],
                                ))
                              ],
                            ),
                            SizedBox(
                              height: size.width * AppDimensions.numD04,
                            ),

                            Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  isLoading
                                      ? Container(
                                          height:
                                              size.width * AppDimensions.numD60,
                                          width:
                                              size.width * AppDimensions.numD70,
                                          alignment: Alignment.center,
                                          child: showAnimatedLoader(size),
                                        )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              size.width *
                                                  AppDimensions.numD04),
                                          child: CachedNetworkImage(
                                            imageUrl: userImage.isEmpty
                                                ? "https://via.placeholder.com/300"
                                                : userImage,
                                            height: size.width *
                                                AppDimensions.numD60,
                                            width: size.width *
                                                AppDimensions.numD70,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                              height: size.width *
                                                  AppDimensions.numD60,
                                              width: size.width *
                                                  AppDimensions.numD70,
                                              alignment: Alignment.center,
                                              child: showAnimatedLoader(size),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              height: size.width *
                                                  AppDimensions.numD65,
                                              width: size.width *
                                                  AppDimensions.numD70,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                    color: const Color.fromARGB(
                                                        255, 223, 223, 223)),
                                                borderRadius:
                                                    BorderRadius.circular(size
                                                            .width *
                                                        AppDimensions.numD04),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    "${iconsPath}ic_user.png",
                                                    width: size.width *
                                                        AppDimensions.numD11,
                                                    color: Colors.grey,
                                                  ),
                                                  SizedBox(
                                                      height: size.width *
                                                          AppDimensions.numD03),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20,
                                                        vertical: 10),
                                                    child: Text(
                                                      "Upload a recent photo or take a selfie. It’s helps you show that you're a verified Hopper, and part of the  PressHop community. Cheers",
                                                      style: commonTextStyle(
                                                        size: size,
                                                        fontSize: size.width *
                                                            AppDimensions
                                                                .numD03,
                                                        color: AppColorTheme
                                                            .colorHint,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                      textAlign:
                                                          TextAlign.justify,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                  // Edit button
                                  Positioned(
                                    right: size.width * AppDimensions.numD02,
                                    bottom: size.width * AppDimensions.numD02,
                                    child: InkWell(
                                      onTap: () => _showImagePicker(context),
                                      child: Container(
                                        padding:
                                            EdgeInsets.all(size.width * 0.007),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.all(
                                              size.width * 0.005),
                                          decoration: const BoxDecoration(
                                            color: AppColorTheme.colorThemePink,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Icon(
                                              Icons.edit_outlined,
                                              color: Colors.white,
                                              size: size.width *
                                                  AppDimensions.numD04,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: size.width * AppDimensions.numD04,
                            ),

                            /// User name
                            // Center(
                            //   child: Text(
                            //     fullName,
                            //     style: commonTextStyle(
                            //         size: size,
                            //         fontSize: size.width * AppDimensions.numD05,
                            //         color: Colors.black,
                            //         fontWeight: FontWeight.bold),
                            //   ),
                            // ),

                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    fullName,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD05,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  // if (state is ProfileLoaded &&
                                  //     state.profile.stripeStatus
                                  //         .stripeStatusActive)
                                  Transform.translate(
                                    offset: const Offset(2, -1),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: size.width *
                                              AppDimensions.numD01),
                                      child: Image.asset(
                                        "${iconsPath}verified_badge.png",
                                        height:
                                            size.width * AppDimensions.numD04,
                                        width:
                                            size.width * AppDimensions.numD04,
                                        // color: const Color(0xFF2D7ADE),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: size.width * AppDimensions.numD04,
                            ),

                            /// Verified button
                            Container(
                                width: size.width * AppDimensions.numD60,
                                padding: EdgeInsets.symmetric(
                                  vertical: size.width * AppDimensions.numD03,
                                  horizontal: size.width * AppDimensions.numD01,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(
                                      size.width * AppDimensions.numD02),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: size.width * AppDimensions.numD03,
                                    ),
                                    Image.asset(
                                      "${iconsPath}ic_verified.png",
                                      height: size.width * AppDimensions.numD06,
                                      width: size.width * AppDimensions.numD06,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: size.width * AppDimensions.numD03,
                                    ),
                                    Text(
                                      AppStrings.verifiedHopperText,
                                      textAlign: TextAlign.start,
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize:
                                              size.width * AppDimensions.numD05,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                )),

                            /// Digital ID Expire
                            Container(
                                width: size.width * AppDimensions.numD60,
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(
                                    top: size.width * AppDimensions.numD04),
                                padding: EdgeInsets.symmetric(
                                  vertical: size.width * AppDimensions.numD03,
                                  horizontal: size.width * AppDimensions.numD03,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD02),
                                    border: Border.all(
                                        width: 1.0, color: Colors.black)),
                                child: RichText(
                                  textAlign: TextAlign.start,
                                  text: TextSpan(
                                    text: AppStrings.digitalIdExpireOnText,
                                    style: TextStyle(
                                        fontSize:
                                            size.width * AppDimensions.numD036,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        height: 1.5),
                                    children: [
                                      TextSpan(
                                        text: DateFormat("dd MMM yyyy")
                                            .format(DateTime.now()),
                                        style: TextStyle(
                                            fontSize: size.width *
                                                AppDimensions.numD036,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            height: 1.5),
                                      )
                                    ],
                                  ),
                                )),

                            SizedBox(
                              height: size.width * AppDimensions.numD04,
                            ),

                            Container(
                                width: size.width * AppDimensions.numD60,
                                padding: EdgeInsets.symmetric(
                                  vertical: size.width * AppDimensions.numD02,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD02),
                                    border: Border.all(
                                        width: 1.0, color: Colors.black)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: size.width * AppDimensions.numD01,
                                    ),
                                    SizedBox(
                                      height: size.width * AppDimensions.numD16,
                                      width: size.width * AppDimensions.numD16,
                                      child: QrImageView(
                                        data: "https://www.presshop.co.uk/",
                                        version: QrVersions.auto,
                                        padding: const EdgeInsets.all(2),
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width * AppDimensions.numD01,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "PressHop Media UK Limited",
                                            style: TextStyle(
                                                fontSize: size.width *
                                                    AppDimensions.numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                                height: 1.5),
                                          ),
                                          Text(
                                            "167-169, Great Portland St",
                                            style: TextStyle(
                                                fontSize: size.width *
                                                    AppDimensions.numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                height: 1.5),
                                          ),
                                          Text(
                                            "London, United Kingdom",
                                            style: TextStyle(
                                                fontSize: size.width *
                                                    AppDimensions.numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                height: 1.5),
                                          ),
                                          Text(
                                            "Company No: 13522872",
                                            style: TextStyle(
                                                fontSize: size.width *
                                                    AppDimensions.numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                height: 1.5),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )),

                            SizedBox(
                              height: size.width * AppDimensions.numD02,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  RotatedBox(
                    quarterTurns: 1,
                    child: Container(
                      alignment: Alignment.center,
                      height: size.width * AppDimensions.numD25,
                      decoration: BoxDecoration(
                          color: AppColorTheme.colorThemePink,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                                size.width * AppDimensions.numD03),
                            topRight: Radius.circular(
                                size.width * AppDimensions.numD03),
                          )),
                      child: Text("PRESS",
                          style: TextStyle(
                            fontSize: size.width * AppDimensions.numD20,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 18.0,
                          )),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _updateUserProfile(ProfileData profile) {
    setState(() {
      if (profile.userName.isNotEmpty || profile.firstName.isNotEmpty) {
        userName =
            profile.userName.isNotEmpty ? profile.userName : profile.firstName;
        sharedPreferences!
            .setString(SharedPreferencesKeys.userNameKey, profile.userName);
      }
      if (profile.firstName.isNotEmpty) {
        String firstName = profile.firstName;
        String lastName = profile.lastName;
        fullName = firstName + (lastName.isNotEmpty ? " $lastName" : "");
        sharedPreferences!
            .setString(SharedPreferencesKeys.firstNameKey, firstName);
        sharedPreferences!
            .setString(SharedPreferencesKeys.lastNameKey, lastName);
      }

      if (profile.profileImage.isNotEmpty) {
        if (profile.profileImage.startsWith("http")) {
          userImage = fixS3Url(profile.profileImage);
        } else {
          userImage = fixS3Url(profile.profileImage);
        }
        sharedPreferences!
            .setString(SharedPreferencesKeys.profileImageKey, userImage);
      }
    });
  }

  void _updateUserImage(String imageUrl) {
    setState(() {
      if (imageUrl.startsWith("http")) {
        userImage = fixS3Url(imageUrl);
      } else {
        userImage = fixS3Url(imageUrl);
      }
      sharedPreferences!
          .setString(SharedPreferencesKeys.profileImageKey, userImage);
    });
    showSnackBar("Success", "Profile image updated successfully", Colors.green);
  }

  // void _launchURL() async {
  //   const url = 'https://www.presshop.co.uk';
  //   final uri = Uri.parse(url);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri, mode: LaunchMode.externalApplication);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }
}
