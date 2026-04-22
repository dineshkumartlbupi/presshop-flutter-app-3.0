import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/constants/string_constants_new2.dart';
import 'task_chat_bubbles.dart';

class RatingReviewBubble extends StatefulWidget {

  const RatingReviewBubble({
    super.key,
    required this.likedFeatures,
    required this.onSubmit,
    this.isAlreadyRated = false,
  });
  final List<String> likedFeatures;
  final Function(double rating, String review, List<String> features) onSubmit;
  final bool isAlreadyRated;

  @override
  State<RatingReviewBubble> createState() => _RatingReviewBubbleState();
}

class _RatingReviewBubbleState extends State<RatingReviewBubble> {
  double currentRating = 0.0;
  final List<String> selectedFeatures = [];
  final TextEditingController reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MediaHouseAvatar(),
        SizedBox(width: size.width * AppDimensions.numD025),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: size.width * AppDimensions.numD06),
            padding: EdgeInsets.symmetric(
              horizontal: size.width * AppDimensions.numD05,
              vertical: size.width * AppDimensions.numD02,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColorTheme.colorGoogleButtonBorder),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(size.width * AppDimensions.numD04),
                bottomLeft: Radius.circular(size.width * AppDimensions.numD04),
                bottomRight: Radius.circular(size.width * AppDimensions.numD04),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.width * AppDimensions.numD04),
                Text(
                  "Rate your experience with PressHop",
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * AppDimensions.numD036,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: size.width * AppDimensions.numD04),
                RatingBar(
                  glowRadius: 0,
                  ratingWidget: RatingWidget(
                    empty: Image.asset("${iconsPath}emptystar.png"),
                    full: Image.asset("${iconsPath}star.png"),
                    half: Image.asset("${iconsPath}ic_half_star.png"),
                  ),
                  onRatingUpdate: (value) =>
                      setState(() => currentRating = value),
                  itemSize: size.width * AppDimensions.numD09,
                  itemCount: 5,
                  initialRating: currentRating,
                  allowHalfRating: true,
                  itemPadding:
                      EdgeInsets.only(left: size.width * AppDimensions.numD03),
                ),
                SizedBox(height: size.width * 0.04),
                const Text("Tell us what you liked about the App",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: size.width * AppDimensions.numD018),
                _buildFeaturesWrap(size),
                SizedBox(height: size.width * AppDimensions.numD02),
                _buildReviewTextField(size),
                SizedBox(height: size.width * AppDimensions.numD04),
                _buildSubmitButton(size),
                SizedBox(height: size.width * 0.01),
                _buildFooterLinks(context, size),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesWrap(Size size) {
    return Wrap(
      children: widget.likedFeatures.map((feature) {
        bool isSelected = selectedFeatures.contains(feature);
        return Container(
          margin: EdgeInsets.symmetric(horizontal: size.width * 0.01),
          child: ChoiceChip(
            label: Text(feature),
            labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColorTheme.colorGrey6),
            selected: isSelected,
            selectedColor: AppColorTheme.colorThemePink,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  selectedFeatures.add(feature);
                } else {
                  selectedFeatures.remove(feature);
                }
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewTextField(Size size) {
    return Stack(
      children: [
        TextFormField(
          controller: reviewController,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: AppStringsNew2.textData,
            contentPadding: EdgeInsets.only(
                left: size.width * AppDimensions.numD08,
                right: size.width * AppDimensions.numD02,
                top: size.width * AppDimensions.numD075),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(size.width * 0.03),
                borderSide: const BorderSide(color: Colors.black)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(size.width * 0.03),
                borderSide: const BorderSide(color: Colors.black)),
          ),
        ),
        Positioned(
          top: size.width * AppDimensions.numD038,
          left: size.width * AppDimensions.numD014,
          child: Image.asset("${iconsPath}docs.png",
              width: size.width * 0.06,
              height: size.width * 0.07,
              color: Colors.grey.shade400),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(Size size) {
    return SizedBox(
      height: size.width * AppDimensions.numD13,
      width: size.width,
      child: commonElevatedButton(
        widget.isAlreadyRated ? "Thanks a Ton" : AppStringsNew2.submitText,
        size,
        commonButtonTextStyle(size),
        commonButtonStyle(size,
            widget.isAlreadyRated ? Colors.grey : AppColorTheme.colorThemePink),
        widget.isAlreadyRated
            ? () {}
            : () => widget.onSubmit(
                currentRating, reviewController.text, selectedFeatures),
      ),
    );
  }

  Widget _buildFooterLinks(BuildContext context, Size size) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontFamily: "AirbnbCereal"),
        children: [
          const TextSpan(text: "Please refer to our "),
          TextSpan(
            text: "Terms & Conditions. ",
            style: const TextStyle(
                color: AppColorTheme.colorThemePink,
                fontWeight: FontWeight.w600),
            recognizer: TapGestureRecognizer()
              ..onTap = () => context
                  .pushNamed(AppRoutes.termName, extra: {'type': 'legal'}),
          ),
          const TextSpan(text: "If you have any questions, please "),
          TextSpan(
            text: "contact ",
            style: const TextStyle(
                color: AppColorTheme.colorThemePink,
                fontWeight: FontWeight.w600),
            recognizer: TapGestureRecognizer()
              ..onTap = () => context.pushNamed(AppRoutes.contactUsName),
          ),
          const TextSpan(text: "us."),
        ],
      ),
    );
  }
}
