import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:presshop/core/core_export.dart';

class AvatarBottomSheet {
  static void show({
    required BuildContext context,
    required Size size,
    required List<AvatarData> avatarList,
    required Function(AvatarData avatar) onAvatarSelected,
    ValueNotifier<bool>? notifier,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        Widget buildContent(bool isLoading) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                height: size.height * 0.6,
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: size.width * AppDimensions.numD04,
                      ),
                      child: Row(
                        children: [
                          Text(
                            AppStrings.chooseAvatarText,
                            style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD05,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            splashRadius: size.width * AppDimensions.numD06,
                            onPressed: () => context.pop(),
                            icon: Icon(
                              Icons.close,
                              color: Colors.black,
                              size: size.width * AppDimensions.numD06,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Avatar grid
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: isLoading
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          size.height * AppDimensions.numD05),
                                  child: showAnimatedLoader(size),
                                )
                              : avatarList.isEmpty
                                  ? const SizedBox.shrink()
                                  : StaggeredGrid.count(
                                      crossAxisCount: 6,
                                      mainAxisSpacing: 3.0,
                                      crossAxisSpacing: 4.0,
                                      axisDirection: AxisDirection.down,
                                      children: avatarList.map<Widget>((item) {
                                        return InkWell(
                                          onTap: () {
                                            // Deselect previously selected avatar
                                            int pos = avatarList.indexWhere(
                                              (element) => element.selected,
                                            );
                                            if (pos >= 0) {
                                              avatarList[pos].selected = false;
                                            }

                                            // Select new avatar
                                            item.selected = true;
                                            setState(() {});

                                            // Callback with selected avatar
                                            onAvatarSelected(item);

                                            // Close bottom sheet
                                            context.pop();
                                          },
                                          child: Stack(
                                            children: [
                                              // Avatar image with shimmer loading
                                              Image.network(
                                                item.avatar,
                                                errorBuilder: (context,
                                                    exception, stackTrace) {
                                                  debugPrint(
                                                      "Error loading avatar from URL: ${item.avatar} \nError: $exception");
                                                  return Image.asset(
                                                    "${CommonAssets.commonImagePath}rabbitLogo.png",
                                                    fit: BoxFit.contain,
                                                    width: size.width *
                                                        AppDimensions.numD20,
                                                    height: size.width *
                                                        AppDimensions.numD20,
                                                  );
                                                },
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey[300]!,
                                                    highlightColor:
                                                        Colors.grey[100]!,
                                                    child: Container(
                                                      width: size.width *
                                                          AppDimensions.numD20,
                                                      height: size.width *
                                                          AppDimensions.numD20,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                8),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              // Selection indicator
                                              if (item.selected)
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: Icon(
                                                    Icons.check,
                                                    color: Colors.black,
                                                    size: size.width *
                                                        AppDimensions.numD06,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }

        if (notifier != null) {
          return ValueListenableBuilder<bool>(
            valueListenable: notifier,
            builder: (context, value, child) => buildContent(value),
          );
        }

        return buildContent(false);
      },
    );
  }
}

class AvatarData {

  AvatarData({
    required this.id,
    required this.avatar,
    this.selected = false,
  });

  factory AvatarData.fromJson(Map<String, dynamic> json) {
    return AvatarData(
      id: (json["_id"] ?? json["id"] ?? "").toString(),
      avatar: (json["avatar"] ?? "").toString(),
      selected: false,
    );
  }
  String id;
  String avatar;
  bool selected;

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "avatar": avatar,
    };
  }
}
