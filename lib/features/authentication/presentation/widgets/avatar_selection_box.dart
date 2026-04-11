import 'package:flutter/material.dart';
import 'package:presshop/core/core_export.dart';

class AvatarSelectionBox extends StatelessWidget {

  const AvatarSelectionBox({
    super.key,
    required this.size,
    required this.selectedAvatar,
    required this.onTap,
    required this.onClear,
  });
  final Size size;
  final String selectedAvatar;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (selectedAvatar.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              height: size.width * AppDimensions.numD30,
              width: size.width * AppDimensions.numD35,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColorTheme.colorTextFieldBorder),
                  borderRadius:
                      BorderRadius.circular(size.width * AppDimensions.numD04)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "${iconsPath}ic_user.png",
                    width: size.width * AppDimensions.numD11,
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD01,
                  ),
                  Text(
                    AppStrings.chooseYourAvatarText,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD03,
                        color: AppColorTheme.colorHint,
                        fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(size.width * AppDimensions.numD04),
              child: Image.network(
                selectedAvatar,
                height: size.width * AppDimensions.numD30,
                width: size.width * AppDimensions.numD35,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: size.width * AppDimensions.numD30,
                  width: size.width * AppDimensions.numD35,
                  color: Colors.grey[300],
                  child: Icon(Icons.error),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: InkWell(
                onTap: onClear,
                child: Container(
                  padding: EdgeInsets.all(size.width * AppDimensions.numD01),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: Icon(Icons.cancel,
                      color: Colors.black,
                      size: size.width * AppDimensions.numD035),
                ),
              ),
            )
          ],
        ),
      );
    }
  }
}
