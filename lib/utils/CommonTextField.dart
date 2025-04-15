import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Common.dart';

class CommonTextField extends StatefulWidget {
  CommonTextField(
      {super.key,
      required this.size,
      required this.controller,
      required this.hintText,
      required this.prefixIcon,
      required this.prefixIconHeight,
      required this.suffixIconIconHeight,
      required this.suffixIcon,
      required this.hidePassword,
      required this.enableValidations,
      required this.filled,
      required this.filledColor,
      required this.keyboardType,
      required this.validator,
      required this.maxLines,
      required this.borderColor,
       this.prefix,
      required this.textInputFormatters,
        this.errorMaxLines,
       this.onChanged,
        this.maxLength,
      this.callback,
      this.autofocus,
      this.readOnly});

  final Size size;
  final TextEditingController controller;
  final String hintText;
  final Widget? prefixIcon;
  final double prefixIconHeight;
  final double suffixIconIconHeight;
  final int? errorMaxLines;
  final Widget? suffixIcon;
  final bool hidePassword;
  final bool enableValidations;
  final bool filled;
  final Color filledColor;
  final Color borderColor;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final String? Function(String?)? onChanged;
  final List<TextInputFormatter>? textInputFormatters;
  final int? maxLength;
  VoidCallback? callback;
  bool? autofocus;
  bool? readOnly;
  final Widget? prefix;

  @override
  State<StatefulWidget> createState() {
    return CommonTextFieldState();
  }
}

class CommonTextFieldState extends State<CommonTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      cursorColor: colorTextFieldIcon,
      obscureText: widget.hidePassword,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      style: TextStyle(color: Colors.black, fontSize: widget.size.width * numD032,fontFamily: 'AirbnbCereal'),
      inputFormatters: widget.textInputFormatters,
      onTap: widget.callback,
      maxLength: widget.maxLength,
      minLines: 1,
      autofocus: widget.autofocus ?? true,
      readOnly: widget.readOnly ?? false,
      decoration: InputDecoration(
        counterText: "",
          filled: widget.filled,
          fillColor: widget.filledColor,
          hintText: widget.hintText,
          errorMaxLines: widget.errorMaxLines,
          errorStyle: const TextStyle(
            color: colorThemePink,
            fontFamily: "AirbnbCereal"
          ),
          hintStyle:
              TextStyle(color: colorHint, fontSize: widget.size.width * numD035,fontFamily: 'AirbnbCereal'),
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.size.width * 0.03),
              borderSide: BorderSide(width: 1, color: widget.borderColor)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.size.width * 0.03),
              borderSide: BorderSide(width: 1, color: widget.borderColor)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.size.width * 0.03),
              borderSide: BorderSide(width: 1, color: widget.borderColor)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.size.width * 0.03),
              borderSide: BorderSide(width: 1, color: widget.borderColor)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.size.width * 0.03),
              borderSide: BorderSide(width: 1, color: widget.borderColor)),
          prefixIcon: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: widget.size.width * numD02),
            child: widget.prefixIcon,
          ),
          prefix: widget.prefix,
          prefixIconConstraints:
              BoxConstraints(maxHeight: widget.prefixIconHeight),
          prefixIconColor: colorTextFieldIcon,
          suffixIcon: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: widget.size.width * numD02),
            child: widget.suffixIcon,
          ),
          suffixIconConstraints:
              BoxConstraints(maxHeight: widget.suffixIconIconHeight),
          suffixIconColor:
              widget.hidePassword ? colorTextFieldIcon : Colors.grey,
      contentPadding: EdgeInsets.symmetric(vertical: widget.size.width*numD02)
      ),
      textAlignVertical: TextAlignVertical.center,
      textCapitalization: TextCapitalization.none,
      onChanged: widget.onChanged,
      validator: widget.validator,
      autovalidateMode: widget.enableValidations
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
    );
  }
}
