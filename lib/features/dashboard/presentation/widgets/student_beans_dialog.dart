import 'package:flutter/material.dart';
import 'package:presshop/core/core_export.dart';
import 'package:go_router/go_router.dart';

class StudentBeansDialog extends StatelessWidget {

  const StudentBeansDialog({
    super.key,
    required this.size,
    this.heading,
    this.description,
    required this.onConfirm,
  });
  final Size size;
  final String? heading;
  final String? description;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      contentPadding: EdgeInsets.zero,
      insetPadding:
          EdgeInsets.symmetric(horizontal: size.width * AppDimensions.numD04),
      content: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius:
                BorderRadius.circular(size.width * AppDimensions.numD045)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogHeader(context),
            _buildDialogDivider(context),
            _buildDialogBody(context),
            _buildDialogFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: size.width * AppDimensions.numD04),
      child: Row(
        children: [
          Text(
            (heading?.isNotEmpty == true
                ? heading
                : "Brains, beans, and breaking news!")!,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: size.width * AppDimensions.numD04,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.close,
              color: Theme.of(context).iconTheme.color,
              size: size.width * AppDimensions.numD06,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDialogDivider(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: size.width * AppDimensions.numD04),
      child: Divider(
        color: Theme.of(context).dividerColor,
        thickness: 0.5,
      ),
    );
  }

  Widget _buildDialogBody(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: size.width * AppDimensions.numD04),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                "assets/rabbits/student_beans_rabbit2.png",
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: size.width * AppDimensions.numD04),
          Expanded(
            child: Text(
              (description?.isNotEmpty == true
                  ? description
                  : "Please confirm your student status to continue")!,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: size.width * AppDimensions.numD035,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDialogFooter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * AppDimensions.numD04,
          vertical: size.width * AppDimensions.numD04),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: SizedBox(
              height: size.width * AppDimensions.numD12,
              child: commonElevatedButton(
                "Confirm",
                size,
                commonButtonTextStyle(size),
                commonButtonStyle(size, AppColorTheme.colorThemePink),
                onConfirm,
              ),
            ),
          )
        ],
      ),
    );
  }
}
