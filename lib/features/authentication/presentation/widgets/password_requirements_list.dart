import 'package:flutter/material.dart';
import 'package:presshop/core/core_export.dart';

class PasswordRequirementRow extends StatelessWidget {

  const PasswordRequirementRow({
    super.key,
    required this.isValid,
    required this.text,
    required this.size,
  });
  final bool isValid;
  final String text;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.asset(
          !isValid ? "${iconsPath}cross.png" : "${iconsPath}check.png",
          width: 15,
          height: 15,
        ),
        SizedBox(width: size.width * 0.02),
        Text(
          text,
          style: TextStyle(
            color: !isValid ? Colors.red : Colors.green,
            fontSize: size.width * 0.03,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class PasswordRequirementsList extends StatelessWidget {

  const PasswordRequirementsList({
    super.key,
    required this.showLowercase,
    required this.showUppercase,
    required this.showNumber,
    required this.showSpecial,
    required this.showMinLength,
    required this.size,
  });
  final bool showLowercase;
  final bool showUppercase;
  final bool showNumber;
  final bool showSpecial;
  final bool showMinLength;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: size.width * 0.03),
        Text(
          "Minimum password requirement",
          style: TextStyle(
            color: Colors.black,
            fontSize: size.width * 0.045,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: size.width * 0.02),
        PasswordRequirementRow(
          isValid: showLowercase,
          text: "Contains at least 01 lowercase character",
          size: size,
        ),
        SizedBox(height: size.width * 0.01),
        PasswordRequirementRow(
          isValid: showSpecial,
          text: "Contains at least 01 special character",
          size: size,
        ),
        SizedBox(height: size.width * 0.01),
        PasswordRequirementRow(
          isValid: showUppercase,
          text: "Contains at least 01 uppercase character",
          size: size,
        ),
        SizedBox(height: size.width * 0.01),
        PasswordRequirementRow(
          isValid: showMinLength,
          text: "Must be at least 08 characters",
          size: size,
        ),
        SizedBox(height: size.width * 0.01),
        PasswordRequirementRow(
          isValid: showNumber,
          text: "Contains at least 01 number",
          size: size,
        ),
      ],
    );
  }
}
