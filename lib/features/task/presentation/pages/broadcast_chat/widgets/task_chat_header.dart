import 'package:flutter/material.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/features/task/domain/entities/task_assigned_entity.dart';

class TaskChatHeader extends StatelessWidget {
  final TaskAssignedEntity taskDetail;

  const TaskChatHeader({super.key, required this.taskDetail});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: size.width * AppDimensions.numD055),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.width * AppDimensions.numD025),
              Row(
                children: [
                  Text(
                    "TASK ACCEPTED",
                    style: commonTextStyle(
                      size: size,
                      fontSize: size.width * AppDimensions.numD035,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  _buildMediaHouseProfile(size),
                ],
              ),
              SizedBox(height: size.width * AppDimensions.numD03),
              Text(
                taskDetail.task.heading,
                style: TextStyle(
                  fontSize: size.width * AppDimensions.numD035,
                  color: Colors.black,
                  fontFamily: "AirbnbCereal",
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: size.width * AppDimensions.numD04),
              priceImageWithButton(
                size,
                taskDetail.task.hopperTaskAmount,
                taskDetail.task.hopperInfo.isNotEmpty
                    ? taskDetail.task.hopperInfo.first.hours
                    : "0",
              ),
              SizedBox(height: size.width * AppDimensions.numD03),
            ],
          ),
        ),
        _buildCheckIcon(size),
      ],
    );
  }

  Widget _buildMediaHouseProfile(Size size) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, spreadRadius: 2),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          taskDetail.task.mediaHouse.profileImage,
          height: size.width * AppDimensions.numD10,
          width: size.width * AppDimensions.numD10,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              "${commonImagePath}rabbitLogo.png",
              height: size.width * AppDimensions.numD10,
              width: size.width * AppDimensions.numD10,
            );
          },
        ),
      ),
    );
  }

  Widget _buildCheckIcon(Size size) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.all(size.width * AppDimensions.numD025),
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: size.width * AppDimensions.numD07,
        ),
      ),
    );
  }
}
