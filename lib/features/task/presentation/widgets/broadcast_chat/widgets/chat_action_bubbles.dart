import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/features/task/presentation/bloc/task_bloc.dart';
import 'package:presshop/features/task/presentation/bloc/task_event.dart';
import 'package:presshop/main.dart';
import 'task_chat_bubbles.dart';

class UploadInfoBubble extends StatelessWidget {
  final String uploadTextType;

  const UploadInfoBubble({super.key, required this.uploadTextType});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MediaHouseAvatar(),
        SizedBox(width: size.width * AppDimensions.numD04),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * AppDimensions.numD03,
              vertical: size.width * AppDimensions.numD02,
            ),
            width: size.width,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(size.width * AppDimensions.numD04),
                bottomLeft: Radius.circular(size.width * AppDimensions.numD04),
                bottomRight: Radius.circular(size.width * AppDimensions.numD04),
              ),
            ),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: size.width * AppDimensions.numD035,
                  color: Colors.black,
                  fontFamily: "AirbnbCereal",
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: uploadTextType == "request_more_content"
                        ? "Please upload more content by clicking the"
                        : "Please upload content by clicking the",
                  ),
                  TextSpan(
                    text: " Gallery or Camera",
                    style: TextStyle(
                      fontSize: size.width * AppDimensions.numD035,
                      color: AppColorTheme.colorThemePink,
                      fontFamily: "AirbnbCereal",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: " buttons below"),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CongratulationsBubble extends StatelessWidget {
  final String roomId;
  final String mediaHouseName;
  final String mediaCount;
  final String amount;
  final String transactionId;

  const CongratulationsBubble({
    super.key,
    required this.roomId,
    required this.mediaHouseName,
    required this.mediaCount,
    required this.amount,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MediaHouseAvatar(),
        SizedBox(width: size.width * AppDimensions.numD04),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * AppDimensions.numD03,
              vertical: size.width * AppDimensions.numD03,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(size.width * AppDimensions.numD04),
                bottomLeft: Radius.circular(size.width * AppDimensions.numD04),
                bottomRight: Radius.circular(size.width * AppDimensions.numD04),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * AppDimensions.numD037,
                      fontFamily: "AirbnbCereal",
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: "Congratulations,",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: ' $mediaHouseName',
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
                            color: AppColorTheme.colorThemePink,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: " have purchased ",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: mediaCount,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
                            color: AppColorTheme.colorThemePink,
                            fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(
                          text: " for ", style: TextStyle(color: Colors.black)),
                      TextSpan(
                        text: "$currencySymbol$amount",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
                            color: AppColorTheme.colorThemePink,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.width * AppDimensions.numD04),
                SizedBox(
                  height: size.width * AppDimensions.numD13,
                  width: size.width,
                  child: commonElevatedButton(
                    "View Transaction Details",
                    size,
                    commonButtonTextStyle(size),
                    commonButtonStyle(size, AppColorTheme.colorThemePink),
                    () {
                      context.read<TaskBloc>().add(
                            GetContentTransactionDetailsEvent(
                              roomId: roomId,
                              mediaHouseId: transactionId,
                            ),
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MoreContentRequestBubble extends StatelessWidget {
  final ManageTaskChatModel item;
  final Function(String event, String type, Map<String, dynamic>? data) onEmit;

  const MoreContentRequestBubble({
    super.key,
    required this.item,
    required this.onEmit,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MediaHouseAvatar(),
        SizedBox(width: size.width * AppDimensions.numD04),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * AppDimensions.numD05,
              vertical: size.width * AppDimensions.numD02,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(size.width * AppDimensions.numD04),
                bottomLeft: Radius.circular(size.width * AppDimensions.numD04),
                bottomRight: Radius.circular(size.width * AppDimensions.numD04),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.width * AppDimensions.numD023),
                Text(
                  "Do you have additional pictures related to the task?",
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * AppDimensions.numD035,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                ),
                SizedBox(height: size.width * AppDimensions.numD04),
                Row(
                  children: [
                    _buildResponseButton(size, "Yes", true),
                    SizedBox(width: size.width * AppDimensions.numD04),
                    _buildResponseButton(size, "No", false),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponseButton(Size size, String label, bool status) {
    bool isSelected = item.requestStatus == status.toString();
    bool isPending = item.requestStatus.isEmpty;

    return Expanded(
      child: SizedBox(
        height: size.width * AppDimensions.numD13,
        child: ElevatedButton(
          onPressed: isPending
              ? () {
                  onEmit(
                      "reqstatus", "", {"chat_id": item.id, "status": status});
                  onEmit("chat message",
                      status ? "contentupload" : "NocontentUpload", null);
                  if (!status) {
                    onEmit("chat message", "rating_hopper", null);
                    onEmit("chat message", "rating_mediaHouse", null);
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isPending
                ? (status ? AppColorTheme.colorThemePink : Colors.black)
                : (isSelected ? Colors.grey : Colors.transparent),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(size.width * AppDimensions.numD04),
              side: isPending || isSelected
                  ? BorderSide.none
                  : const BorderSide(color: Colors.black),
            ),
          ),
          child: Text(
            label,
            style: commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD04,
                color: Colors.white,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class EarningBubble extends StatelessWidget {
  final String amount;

  const EarningBubble({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MediaHouseAvatar(),
        SizedBox(width: size.width * AppDimensions.numD04),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * AppDimensions.numD03,
              vertical: size.width * AppDimensions.numD03,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(size.width * AppDimensions.numD04),
                bottomLeft: Radius.circular(size.width * AppDimensions.numD04),
                bottomRight: Radius.circular(size.width * AppDimensions.numD04),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * AppDimensions.numD037,
                      fontFamily: "AirbnbCereal",
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: "Woohoo! We have paid",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: " $currencySymbol$amount",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
                            color: AppColorTheme.colorThemePink,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: " into your bank account. Please visit ",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: "My Earnings",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
                            color: AppColorTheme.colorThemePink,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: " to view your transaction",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.width * AppDimensions.numD04),
                SizedBox(
                  height: size.width * AppDimensions.numD13,
                  width: size.width,
                  child: commonElevatedButton(
                    "View My Earnings",
                    size,
                    commonButtonTextStyle(size),
                    commonButtonStyle(size, AppColorTheme.colorThemePink),
                    () {
                      context.pushNamed(
                        AppRoutes.myEarningName,
                        extra: {
                          'openDashboard': false,
                          'initialTapPosition': 0,
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MediaUploadSuccessBubble extends StatelessWidget {
  final String imgCount;
  final String vidCount;
  final String audioCount;

  const MediaUploadSuccessBubble({
    super.key,
    required this.imgCount,
    required this.vidCount,
    required this.audioCount,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MediaHouseAvatar(),
        SizedBox(width: size.width * AppDimensions.numD04),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * AppDimensions.numD03,
              vertical: size.width * AppDimensions.numD03,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(size.width * AppDimensions.numD04),
                bottomLeft: Radius.circular(size.width * AppDimensions.numD04),
                bottomRight: Radius.circular(size.width * AppDimensions.numD04),
              ),
            ),
            child: RichText(
              text: TextSpan(
                style: commonTextStyle(
                  size: size,
                  fontSize: size.width * AppDimensions.numD036,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
                children: [
                  const TextSpan(text: "Thanks, you've uploaded "),
                  TextSpan(
                    text: _buildMediaCountText(),
                    style: commonTextStyle(
                      size: size,
                      fontSize: size.width * AppDimensions.numD036,
                      color: AppColorTheme.colorThemePink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _buildMediaCountText() {
    List<String> parts = [];
    if (imgCount.isNotEmpty && imgCount != "0") {
      parts.add("$imgCount ${int.parse(imgCount) > 1 ? 'Photos' : 'Photo'}");
    }
    if (vidCount.isNotEmpty && vidCount != "0") {
      parts.add("$vidCount ${int.parse(vidCount) > 1 ? 'Videos' : 'Video'}");
    }
    if (audioCount.isNotEmpty && audioCount != "0") {
      parts
          .add("$audioCount ${int.parse(audioCount) > 1 ? 'Audios' : 'Audio'}");
    }
    return parts.join(", ");
  }
}

class ActionResponseBubble extends StatelessWidget {
  final String message;

  const ActionResponseBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    bool isYes = message.toLowerCase() == "yes";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(size.width * AppDimensions.numD04),
            decoration: BoxDecoration(
              color: isYes
                  ? AppColorTheme.colorLightGreen.withOpacity(0.15)
                  : AppColorTheme.colorThemePink.withOpacity(0.15),
              border: Border.all(
                color: isYes
                    ? AppColorTheme.colorLightGreen
                    : AppColorTheme.colorThemePink,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(size.width * AppDimensions.numD04),
                bottomLeft: Radius.circular(size.width * AppDimensions.numD04),
                bottomRight: Radius.circular(size.width * AppDimensions.numD04),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  isYes ? Icons.check_circle : Icons.cancel,
                  color: isYes
                      ? AppColorTheme.colorLightGreen
                      : AppColorTheme.colorThemePink,
                  size: size.width * AppDimensions.numD05,
                ),
                SizedBox(width: size.width * AppDimensions.numD02),
                Text(
                  message,
                  textAlign: TextAlign.right,
                  style: commonTextStyle(
                    size: size,
                    fontSize: size.width * AppDimensions.numD036,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: size.width * AppDimensions.numD02),
        const HopperAvatar(),
      ],
    );
  }
}

class UploadNoContentBubble extends StatelessWidget {
  const UploadNoContentBubble({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MediaHouseAvatar(),
        SizedBox(width: size.width * AppDimensions.numD04),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(size.width * AppDimensions.numD04),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(size.width * AppDimensions.numD04),
                bottomLeft: Radius.circular(size.width * AppDimensions.numD04),
                bottomRight: Radius.circular(size.width * AppDimensions.numD04),
              ),
            ),
            child: Text(
              "I don't have additional content for now",
              style: commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD036,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MediaHouseOfferBubble extends StatelessWidget {
  final ManageTaskChatModel item;
  final bool isMakeCounter;

  const MediaHouseOfferBubble({
    super.key,
    required this.item,
    required this.isMakeCounter,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: size.width * AppDimensions.numD026,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MediaHouseAvatar(),
          SizedBox(width: size.width * AppDimensions.numD04),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(size.width * AppDimensions.numD05),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(size.width * AppDimensions.numD04),
                  bottomLeft:
                      Radius.circular(size.width * AppDimensions.numD04),
                  bottomRight:
                      Radius.circular(size.width * AppDimensions.numD04),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD036,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                      children: [
                        TextSpan(
                          text: "${item.mediaHouseName} ",
                          style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
                            color: AppColorTheme.colorThemePink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: "has sent an offer of "),
                        TextSpan(
                          text: "$currencySymbol${item.hopperPrice} ",
                          style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
                            color: AppColorTheme.colorThemePink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: "for your content"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionRequiredBubble extends StatelessWidget {
  final ManageTaskChatModel item;
  final Function(String event, String type, Map<String, dynamic> data) onEmit;

  const ActionRequiredBubble({
    super.key,
    required this.item,
    required this.onEmit,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MediaHouseAvatar(),
        SizedBox(width: size.width * AppDimensions.numD04),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(size.width * AppDimensions.numD04),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(size.width * AppDimensions.numD04),
                bottomLeft: Radius.circular(size.width * AppDimensions.numD04),
                bottomRight: Radius.circular(size.width * AppDimensions.numD04),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.message,
                  style: commonTextStyle(
                    size: size,
                    fontSize: size.width * AppDimensions.numD036,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.width * AppDimensions.numD04),
                Row(
                  children: item.options.map((option) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD01,
                        ),
                        child: SizedBox(
                          height: size.width * AppDimensions.numD13,
                          child: commonElevatedButton(
                            option,
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(
                              size,
                              option.toLowerCase() == "yes"
                                  ? AppColorTheme.colorLightGreen
                                  : AppColorTheme.colorThemePink,
                            ),
                            () {
                              onEmit(
                                "chat message",
                                "action_response",
                                {
                                  "message": option,
                                  "original_message_id": item.id,
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
