import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:presshop/core/widgets/common_app_bar.dart';
import '../../../dashboard/presentation/pages/Dashboard.dart';
import '../../presentation/bloc/profile_bloc.dart';
import '../../presentation/bloc/profile_event.dart';
import '../../presentation/bloc/profile_state.dart';
import 'package:presshop/core/di/injection_container.dart';
import '../../domain/entities/profile_data.dart'; // Ensure this entity exists

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
  final bool _isUploading = false;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    String firstName = sharedPreferences!.getString(firstNameKey) ?? "Hopper";
    String lastName = sharedPreferences!.getString(lastNameKey) ?? "";
    fullName = firstName + (lastName.isNotEmpty ? " $lastName" : "");
    userName = sharedPreferences!.getString(userNameKey) ?? "Hopper";
    // Setup initial image from prefs if available
    String sessionAvatar = sharedPreferences!.getString(avatarKey) ?? "";
    if (sessionAvatar.isNotEmpty) {
       userImage = sessionAvatar;
    }
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery, context);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera, context);
                  Navigator.of(context).pop();
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
        context.read<ProfileBloc>().add(UploadProfileImageEvent(pickedFile.path));
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => sl<ProfileBloc>()..add(FetchProfileEvent()),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
             _updateUserProfile(state.profile);
          } else if (state is ProfileImageUploaded) {
             _updateUserImage(state.imageUrl);
          } else if (state is ProfileError) {
             Fluttertoast.showToast(msg: state.message);
          }
        },
        builder: (context, state) {
          // You might want to show loading indicator if strictly needed, 
          // but for profile fetch we might just show skeleton or current data.
          // For uploading, we set a local flag or check state.
          bool isLoading = state is ProfileLoading;

          return Scaffold(
            appBar: CommonAppBar(
              elevation: 0,
              title: Text(
                digitalId,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * appBarHeadingFontSize),
              ),
              centerTitle: true,
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
            body: Container(
              margin: EdgeInsets.only(
                left: size.width * numD02,
                right: size.width * numD02,
                top: size.width * numD02,
                bottom: size.width * numD1,
              ),
              decoration: BoxDecoration(
                  color: colorLightGrey,
                  borderRadius: BorderRadius.circular(size.width * numD03),
                  border: Border.all(width: 1.0, color: Colors.black)),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                   Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: EdgeInsets.only(
                  left: size.width * numD03,
                  right: size.width * numD28,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    //mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: size.width * numD03,
                      ),

                      /// Rabbit logo
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Image.asset(
                            "${commonImagePath}rabbitLogo.png",
                            height: size.width * numD28,
                            // width: size.width * numD1,
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
                                        fontSize: size.width * numD065,
                                        color: Colors.black,
                                        fontFamily: "AirbnbCereal",
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Text(
                                    "hop",
                                    style: TextStyle(
                                        fontSize: size.width * numD065,
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
                                    fontSize: size.width * numD04,
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
                        height: size.width * numD04,
                      ),

                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                             isLoading && _isUploading // Only show spinner if explicitly uploading or initial load?
                             // Actually better to check isLoading generally for profile fetch too if we want.
                             // But matching original:
                                ? Container(
                                    height: size.width * numD60,
                                    width: size.width * numD70,
                                    alignment: Alignment.center,
                                    child: const CircularProgressIndicator(),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04),
                                    child: CachedNetworkImage(
                                      imageUrl: userImage.isEmpty
                                          ? "https://via.placeholder.com/300"
                                          : userImage,
                                      height: size.width * numD60,
                                      width: size.width * numD70,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        height: size.width * numD60,
                                        width: size.width * numD70,
                                        alignment: Alignment.center,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        height: size.width * numD65,
                                        width: size.width * numD70,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 223, 223, 223)),
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD04),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              "${iconsPath}ic_user.png",
                                              width: size.width * numD11,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(
                                                height: size.width * numD03),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                              child: Text(
                                                "Upload a recent photo or take a selfie. It’s helps you show that you're a verified Hopper, and part of the  PressHop community. Cheers",
                                                style: commonTextStyle(
                                                  size: size,
                                                  fontSize: size.width * numD03,
                                                  color: colorHint,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                                textAlign: TextAlign.justify,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                            // Edit button
                            Positioned(
                              right: size.width * numD02,
                              bottom: size.width * numD02,
                              child: InkWell(
                                onTap: () => _showImagePicker(context),
                                child: Container(
                                  padding: EdgeInsets.all(size.width * 0.007),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(size.width * 0.005),
                                    decoration: const BoxDecoration(
                                      color: colorThemePink,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Icon(
                                        Icons.edit_outlined,
                                        color: Colors.white,
                                        size: size.width * numD04,
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
                        height: size.width * numD04,
                      ),

                      /// User name
                      Center(
                        child: Text(
                          fullName,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD05,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: size.width * numD04,
                      ),

                      /// Verified button
                      Container(
                          width: size.width * numD60,
                          padding: EdgeInsets.symmetric(
                            vertical: size.width * numD03,
                            horizontal: size.width * numD01,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius:
                                BorderRadius.circular(size.width * numD02),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: size.width * numD03,
                              ),
                              Image.asset(
                                "${iconsPath}ic_verified.png",
                                height: size.width * numD06,
                                width: size.width * numD06,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: size.width * numD03,
                              ),
                              Text(
                                verifiedHopperText,
                                textAlign: TextAlign.start,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD05,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          )),

                      /// Digital ID Expire
                      Container(
                          width: size.width * numD60,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: size.width * numD04),
                          padding: EdgeInsets.symmetric(
                            vertical: size.width * numD03,
                            horizontal: size.width * numD03,
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(size.width * numD02),
                              border:
                                  Border.all(width: 1.0, color: Colors.black)),
                          child: RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              text: digitalIdExpireOnText,
                              style: TextStyle(
                                  fontSize: size.width * numD036,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5),
                              children: [
                                TextSpan(
                                  text: DateFormat("dd MMM yyyy")
                                      .format(DateTime.now()),
                                  style: TextStyle(
                                      fontSize: size.width * numD036,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      height: 1.5),
                                )
                              ],
                            ),
                          )),

                      SizedBox(
                        height: size.width * numD04,
                      ),

                      Container(
                          width: size.width * numD60,
                          padding: EdgeInsets.symmetric(
                            vertical: size.width * numD02,
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(size.width * numD02),
                              border:
                                  Border.all(width: 1.0, color: Colors.black)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: size.width * numD01,
                              ),
                              SizedBox(
                                height: size.width * numD16,
                                width: size.width * numD16,
                                child: QrImageView(
                                  data: "https://www.presshop.co.uk/",
                                  version: QrVersions.auto,
                                  padding: const EdgeInsets.all(2),
                                ),
                              ),
                              SizedBox(
                                width: size.width * numD01,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "PressHop Media UK Limited",
                                      style: TextStyle(
                                          fontSize: size.width * numD03,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          height: 1.5),
                                    ),
                                    Text(
                                      "167-169, Great Portland St",
                                      style: TextStyle(
                                          fontSize: size.width * numD03,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          height: 1.5),
                                    ),
                                    Text(
                                      "London, United Kingdom",
                                      style: TextStyle(
                                          fontSize: size.width * numD03,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          height: 1.5),
                                    ),
                                    Text(
                                      "Company No: 13522872",
                                      style: TextStyle(
                                          fontSize: size.width * numD03,
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
                        height: size.width * numD02,
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
                      height: size.width * numD25,
                      decoration: BoxDecoration(
                          color: colorThemePink,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(size.width * numD03),
                            topRight: Radius.circular(size.width * numD03),
                          )),
                      child: Text("PRESS",
                          style: TextStyle(
                            fontSize: size.width * numD20,
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
      userName = profile.userName ?? profile.firstName ?? "Hopper";
      if (profile.profileImage != null && profile.profileImage!.isNotEmpty) {
         if (profile.profileImage!.startsWith("http")) {
            userImage = profile.profileImage!;
         } else {
            userImage ="${url}"+"${profile.profileImage}";
         }
      }
    });
  }

  void _updateUserImage(String imageUrl) {
     setState(() {
       userImage = imageUrl.startsWith("http") ? imageUrl : "$url" + "$imageUrl";
       sharedPreferences!.setString(avatarKey, userImage);
     });
     showSnackBar("Success", "Profile image updated successfully", Colors.green);
  }

  void _launchURL() async {
    const url = 'https://www.presshop.co.uk';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}

//   Widget oldDigitalId() {
//       size = MediaQuery.of(context).size;
//     return SingleChildScrollView(
//       child: Container(
//         margin: EdgeInsets.only(
//           left: size.width * numD05,
//           right: size.width * numD05,
//           top: size.width * numD02,
//           bottom: size.width * numD1,
//         ),
//         decoration: BoxDecoration(
//             color: colorLightGrey,
//             borderRadius: BorderRadius.circular(size.width * numD03),
//             border: Border.all(width: 1.0, color: Colors.black)),
//         padding: EdgeInsets.only(
//           left: size.width * numD05,
//           right: size.width * numD05,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               height: size.width * numD09,
//             ),

//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                     child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Container(
//                       alignment: Alignment.center,
//                       height: size.width * numD30,
//                       width: size.width * numD30,
//                       decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(width: 1.5, color: Colors.black),
//                           image: DecorationImage(
//                             image: NetworkImage(userImage),
//                             fit: BoxFit.cover,
//                             onError: (context, stacktrace) {
//                               Padding(
//                                 padding: EdgeInsets.all(size.width * numD07),
//                                 child: Image.asset(
//                                   "${commonImagePath}rabbitLogo.png",
//                                 ),
//                               );
//                             },
//                           )),
//                       child: ClipRRect(
//                         borderRadius:
//                             BorderRadius.circular(size.width * numD08),
//                         /*child: Image.network(
//                             height: size.width * numD20,
//                             width: size.width * numD20,
//                             userImage,
//                             // fit: BoxFit.cover,
//                             errorBuilder: (context, exception, stacktrace) {
//                               return Padding(
//                                 padding: EdgeInsets.all(size.width * numD07),
//                                 child: Image.asset(
//                                   "${commonImagePath}rabbitLogo.png",
//                                 ),
//                               );
//                             },
//                           ),*/
//                       ),
//                     ),

//                     SizedBox(
//                       height: size.width * numD03,
//                     ),

//                     /// Name
//                     Container(
//                       alignment: Alignment.center,
//                       margin: EdgeInsets.only(
//                         left: size.width * numD02,
//                         bottom: size.width * numD05,
//                       ),
//                       child: Text(
//                         userName,
//                         style: commonTextStyle(
//                             size: size,
//                             fontSize: size.width * numD05,
//                             color: Colors.black,
//                             fontWeight: FontWeight.w500),
//                       ),
//                     ),
//                   ],
//                 )),
//                 Expanded(
//                   child: Container(
//                     alignment: Alignment.centerRight,
//                     height: size.width * numD30,
//                     child: QrImageView(
//                       // data: "$userId\n https://www.presshop.co.uk",
//                       data: Platform.isAndroid
//                           ? "https://play.google.com/store/apps/details?id="
//                           : "https://apps.apple.com/in/app/",
//                       version: QrVersions.auto,
//                     ),
//                   ),
//                 )
//               ],
//             ),

//             Container(
//                 padding: EdgeInsets.symmetric(
//                   vertical: size.width * numD03,
//                   horizontal: size.width * numD03,
//                 ),
//                 decoration: BoxDecoration(
//                   color: colorThemePink,
//                   borderRadius: BorderRadius.circular(size.width * numD03),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Image.asset(
//                       "${iconsPath}ic_verified.png",
//                       height: size.width * numD085,
//                       width: size.width * numD085,
//                       color: Colors.white,
//                     ),
//                     SizedBox(
//                       width: size.width * numD05,
//                     ),
//                     Text(
//                       verifiedHopperText,
//                       textAlign: TextAlign.start,
//                       style: commonTextStyle(
//                           size: size,
//                           fontSize: size.width * numD06,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w500),
//                     ),
//                   ],
//                 )),

//             /// Digital ID Expire
//             Container(
//                 width: size.width,
//                 alignment: Alignment.center,
//                 margin: EdgeInsets.only(top: size.width * numD05),
//                 padding: EdgeInsets.symmetric(
//                   vertical: size.width * numD03,
//                   horizontal: size.width * numD03,
//                 ),
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(size.width * numD03),
//                     border: Border.all(width: 1.0, color: Colors.black)),
//                 child: RichText(
//                   textAlign: TextAlign.start,
//                   text: TextSpan(
//                     text: digitalIdExpireOnText,
//                     style: TextStyle(
//                         fontSize: size.width * numD038,
//                         color: Colors.black,
//                         fontWeight: FontWeight.w400,
//                         height: 1.5),
//                     children: [
//                       TextSpan(
//                         text: DateFormat("dd MMM yyyy").format(DateTime.now()),
//                         style: TextStyle(
//                             fontSize: size.width * numD038,
//                             color: Colors.black,
//                             fontWeight: FontWeight.w600,
//                             height: 1.5),
//                       )
//                     ],
//                   ),
//                 )),

//             /// Company Address

//             Container(
//                 margin: EdgeInsets.only(top: size.width * numD05),
//                 padding: EdgeInsets.symmetric(
//                   vertical: size.width * numD05,
//                   horizontal: size.width * numD03,
//                 ),
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(size.width * numD03),
//                     border: Border.all(width: 1.0, color: Colors.black)),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       width: size.width / 4,
//                       child: Image.asset(
//                         "${iconsPath}ic_digitalId_logo.png",
//                         height: size.width * numD28,
//                       ),
//                     ),
//                     SizedBox(
//                       width: size.width * numD02,
//                     ),
//                     /*  Expanded(
//                           child: RichText(
//                         textAlign: TextAlign.start,
//                         text: TextSpan(
//                           text: mediaUk,
//                           style: TextStyle(
//                               fontSize: size.width * numD038,
//                               color: Colors.black,
//                               fontWeight: FontWeight.w600,
//                               height: 1.5),
//                           children: [
//                             TextSpan(
//                               text: companyName,
//                               style: TextStyle(
//                                   fontSize: size.width * numD038,
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.w400,
//                                   height: 1.5),
//                             )
//                           ],
//                         ),
//                       )),*/
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Presso Media UK Limited",
//                             style: TextStyle(
//                                 fontSize: size.width * numD036,
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.w600,
//                                 height: 1.5),
//                           ),
//                           Text(
//                             "Company number:13522872",
//                             style: TextStyle(
//                                 fontSize: size.width * numD033,
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.w400,
//                                 height: 1.5),
//                           ),
//                           Text(
//                             "167-169, Great Portland Street",
//                             style: TextStyle(
//                                 fontSize: size.width * numD033,
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.w400,
//                                 height: 1.5),
//                           ),
//                           Text(
//                             "London, W1W 5PF",
//                             style: TextStyle(
//                                 fontSize: size.width * numD033,
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.w400,
//                                 height: 1.5),
//                           ),
//                           Text(
//                             "hello@presshop.co.uk",
//                             style: TextStyle(
//                                 fontSize: size.width * numD035,
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.bold,
//                                 height: 1.5),
//                           ),
//                           InkWell(
//                             onTap: () {
//                               _launchURL();
//                             },
//                             child: Text(
//                               "www.presshop.co.uk",
//                               style: TextStyle(
//                                   decoration: TextDecoration.underline,
//                                   fontSize: size.width * numD036,
//                                   color: Colors.blue,
//                                   fontWeight: FontWeight.w500,
//                                   height: 1.5),
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   ],
//                 )),
//             SizedBox(
//               height: size.width * numD045,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
