import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:presshop/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool?> showLocationPermissionDialogWithImage({
  required BuildContext context,
  required Size size,
  String? heading,
  String? description,
  String imagePath = "assets/rabbits/yellow_rabbit.png",
  bool showCloseIcon = false,
  String privacyPolicyUrl = "https://presshop.news/privacy-policy",
  String? buttonText,
  String? cancelText,
}) {
  final String displayHeading = (heading != null && heading.isNotEmpty)
      ? heading
      : "Allow location access";

  final String displayDescription = (description != null &&
          description.isNotEmpty)
      ? description
      : "PressHop collects your precise location, including background location, to:<br><br><ul><li>Show nearby news tasks</li><li>Verify event proximity and task completion</li><li>Enable live reporting and contributor safety</li></ul><br>Location data may be collected even when the app is closed or not in use.<br><br>You can change or disable location access anytime in your device settings.";

  return showDialog<bool>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      bool isChecked = false;

      return WillPopScope(
        onWillPop: () async => false,
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              contentPadding: EdgeInsets.zero,
              insetPadding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
              content: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size.width * 0.045),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// 🔹 Header
                      SizedBox(height: size.width * 0.06),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayHeading,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (showCloseIcon)
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.black,
                                  size: size.width * 0.06,
                                ),
                              ),
                          ],
                        ),
                      ),

                      /// Divider
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                          vertical: 10,
                        ),
                        child: const Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                      ),

                      /// 🔹 Image + Description
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Image Box
                            Container(
                              width: 120, // fixed width
                              height: 120, // fixed height
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: imagePath.startsWith('http')
                                    ? CachedNetworkImage(
                                        imageUrl: imagePath,
                                        fit: BoxFit.cover,
                                        errorWidget:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                          "assets/rabbits/yellow_rabbit.png",
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Image.asset(
                                        imagePath,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                          "assets/rabbits/yellow_rabbit.png",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                            ),

                            SizedBox(width: size.width * 0.04),

                            /// Text
                            Expanded(
                              child: Html(
                                data: displayDescription,
                                style: {
                                  "body": Style(
                                    textAlign: TextAlign.justify,
                                    color: Colors.black87,
                                    fontSize: FontSize(size.width * 0.035),
                                    fontWeight: FontWeight.w500,
                                    lineHeight: LineHeight(1.2),
                                    padding: HtmlPaddings.zero,
                                    margin: Margins.zero,
                                  ),
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: size.width * 0.04),

                      /// Checkbox + Learn More
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: size.width * 0.08,
                              height: size.width * 0.06,
                              color: Colors.white,
                              child: Checkbox(
                                value: isChecked,
                                activeColor: AppColorTheme.colorThemePink,
                                onChanged: (val) {
                                  setState(() {
                                    isChecked = val ?? false;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isChecked = !isChecked;
                                  });
                                },
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: size.width * 0.035,
                                      color: Colors.black87,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text:
                                            "I agree to the collection and use of my location data as described. ",
                                      ),
                                      TextSpan(
                                        text: "Learn more",
                                        style: TextStyle(
                                          color: AppColorTheme.colorThemePink,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            const url =
                                                "https://www.presshop.com/privacypolicy";
                                            final uri = Uri.parse(url);
                                            if (await canLaunchUrl(uri)) {
                                              await launchUrl(
                                                uri,
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                            }
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: size.width * 0.02),

                      /// 🔹 Buttons
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setBool(
                                    'location_permission_denied',
                                    true,
                                  );
                                  Navigator.pop(context, false);
                                },
                                child: Text(
                                  cancelText ?? "Don't Allow",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: size.width * 0.04,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isChecked
                                      ? AppColorTheme.colorThemePink
                                      : Colors.grey,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: isChecked
                                    ? () async {
                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        await prefs.setBool(
                                          'location_permission_denied',
                                          false,
                                        );
                                        Navigator.pop(context, true);
                                      }
                                    : null,
                                child: Text(
                                  buttonText ?? "Allow",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size.width * 0.04,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.width * 0.04),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
