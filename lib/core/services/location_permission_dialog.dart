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
  String imagePath = "assets/location/image.png",
  bool showCloseIcon = false,
  String privacyPolicyUrl = "https://presshop.news/privacy-policy",
  String? buttonText,
  String? cancelText,
}) {
  final String displayHeading = (heading != null && heading.isNotEmpty)
      ? heading
      : "Want More Tasks? Turn on your location 📍";

  final String displayDescription = (description != null &&
          description.isNotEmpty)
      ? description
      : "<b>PressShop®</b> uses your location to send you nearby tasks, verify event coverage, and help keep you safe while reporting.<br><br>We only access your location when it’s needed - like when the app is open, or when you're moving. It's never used for ads. You're always in control.<br><br><b>Stay local. Stay ready. Start earning.</b>";

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
              insetPadding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              content: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size.width * 0.08),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// 🔹 Header
                      SizedBox(height: size.width * 0.08),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.07,
                        ),
                        child: Text(
                          displayHeading,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: size.width * 0.046,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),

                      /// Divider
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: size.width * 0.03,
                        ),
                        child: Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ),

                      /// 🔹 Image + Description
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.06,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: size.width * 0.04),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Mascot Box
                                Container(
                                  width: size.width * 0.24,
                                  height: size.width * 0.24,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD9E27D),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.asset(
                                      "assets/commonImages/rabbitLogo.png",
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          const Icon(Icons.location_on,
                                              size: 40,
                                              color:
                                                  AppColorTheme.colorThemePink),
                                    ),
                                  ),
                                ),

                                SizedBox(width: size.width * 0.04),

                                /// First Paragraph (Next to Image)
                                Expanded(
                                  child: Html(
                                    data:
                                        displayDescription.contains("<br><br>")
                                            ? displayDescription
                                                .split("<br><br>")[0]
                                            : displayDescription,
                                    style: {
                                      "body": Style(
                                        textAlign: TextAlign.start,
                                        color: Colors.black.withOpacity(0.85),
                                        fontSize: FontSize(size.width * 0.038),
                                        fontWeight: FontWeight.w500,
                                        lineHeight: const LineHeight(1.25),
                                        padding: HtmlPaddings.zero,
                                        margin: Margins.zero,
                                      ),
                                      "b": Style(fontWeight: FontWeight.bold),
                                    },
                                  ),
                                ),
                              ],
                            ),

                            /// Subsequent Paragraphs (Below Row)
                            if (displayDescription.contains("<br><br>")) ...[
                              SizedBox(height: size.width * 0.05),
                              Html(
                                data: displayDescription.substring(
                                    displayDescription.indexOf("<br><br>") + 8),
                                style: {
                                  "body": Style(
                                    textAlign: TextAlign.start,
                                    color: Colors.black.withOpacity(0.85),
                                    fontSize: FontSize(size.width * 0.038),
                                    fontWeight: FontWeight.w500,
                                    lineHeight: const LineHeight(1.3),
                                    padding: HtmlPaddings.zero,
                                    margin: Margins.zero,
                                  ),
                                  "b": Style(fontWeight: FontWeight.bold),
                                },
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(height: size.width * 0.05),

                      /// Checkbox + Learn More
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.scale(
                              scale: 0.9,
                              child: Checkbox(
                                value: isChecked,
                                activeColor: AppColorTheme.colorThemePink,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
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
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: size.width * 0.036,
                                        color: Colors.black.withOpacity(0.8),
                                        height: 1.3,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text:
                                              "I agree to the collection and use of my location data as described. ",
                                        ),
                                        TextSpan(
                                          text: "Learn more",
                                          style: const TextStyle(
                                            color: AppColorTheme.colorThemePink,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              const url =
                                                  "https://www.presshop.com/privacypolicy";
                                              final uri = Uri.parse(url);
                                              if (await canLaunchUrl(uri)) {
                                                await launchUrl(uri,
                                                    mode: LaunchMode
                                                        .externalApplication);
                                              }
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: size.width * 0.05),

                      /// 🔹 Buttons
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.08,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool(
                                    'location_permission_denied', true);
                                Navigator.pop(context, false);
                              },
                              child: Text(
                                cancelText ?? "Cancel",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: size.width * 0.048,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isChecked
                                    ? AppColorTheme.colorThemePink
                                    : Colors.grey.shade400,
                                elevation: 0,
                                fixedSize:
                                    Size(size.width * 0.42, size.width * 0.12),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(size.width * 0.025),
                                ),
                              ),
                              onPressed: isChecked
                                  ? () async {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setBool(
                                          'location_permission_denied', false);
                                      Navigator.pop(context, true);
                                    }
                                  : null,
                              child: Text(
                                buttonText ?? "Okay",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * 0.048,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.width * 0.08),
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
