import 'package:flutter/material.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/features/publish/data/models/tutorials_model.dart';

class TutorialItemCard extends StatelessWidget {
  final TutorialsModel item;
  final Size size;
  final VoidCallback onTap;

  const TutorialItemCard({
    super.key,
    required this.item,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: size.width * AppDimensions.numD04,
            vertical: size.width * AppDimensions.numD04),
        decoration: BoxDecoration(
            border: Border.all(color: AppColorTheme.colorTextFieldIcon),
            borderRadius:
                BorderRadius.circular(size.width * AppDimensions.numD04)),
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(size.width * AppDimensions.numD04),
              child: Stack(
                children: [
                  item.thumbnail.isNotEmpty
                      ? Image.network(
                          getMediaImageUrl(item.thumbnail),
                          height: size.width * AppDimensions.numD30,
                          width: size.width,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return Image.asset(
                              "${commonImagePath}rabbitLogo.png",
                              width: size.width,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          "${dummyImagePath}placeholderImage.png",
                          height: size.width * AppDimensions.numD30,
                          width: size.width,
                          fit: BoxFit.cover,
                        ),
                  Positioned(
                    right: size.width * AppDimensions.numD02,
                    top: size.width * AppDimensions.numD02,
                    child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD01,
                            vertical: size.width * 0.002),
                        decoration: BoxDecoration(
                            color:
                                AppColorTheme.colorLightGreen.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(
                                size.width * AppDimensions.numD015)),
                        child: Icon(
                          Icons.videocam_outlined,
                          size: size.width * AppDimensions.numD045,
                          color: Colors.white,
                        )),
                  )
                ],
              ),
            ),
            SizedBox(
              height: size.width * AppDimensions.numD01,
            ),
            Text(item.description,
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * AppDimensions.numD03,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const Spacer(),
            Row(
              children: [
                Image.asset(
                  "${iconsPath}ic_clock.png",
                  height: size.width * AppDimensions.numD03,
                ),
                SizedBox(
                  width: size.width * AppDimensions.numD01,
                ),
                Text(
                  item.duration,
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * AppDimensions.numD025,
                      color: AppColorTheme.colorHint,
                      fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Image.asset(
                  "${iconsPath}ic_view.png",
                  height: size.width * AppDimensions.numD03,
                ),
                SizedBox(
                  width: size.width * AppDimensions.numD01,
                ),
                Text(
                  item.view.toString(),
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * AppDimensions.numD025,
                      color: AppColorTheme.colorThemePink,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(
              height: size.width * AppDimensions.numD01,
            ),
          ],
        ),
      ),
    );
  }
}
