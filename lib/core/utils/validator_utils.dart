import 'package:presshop/core/constants/string_constants_new.dart';
import 'package:presshop/core/constants/regex_constants.dart';

String? checkRequiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return AppStrings.requiredText;
  }
  return null;
}

String? checkEmailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return AppStrings.requiredText;
  } else if (!emailExpression.hasMatch(value)) {
    return AppStrings.emailErrorText;
  }
  return null;
}

String? checkPhoneValidator(String? value) {
  if (value == null || value.isEmpty) {
    return AppStrings.requiredText;
  } else if (value.length < 10) {
    return AppStrings.phoneErrorText;
  }
  return null;
}

String? checkPasswordValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return AppStrings.requiredText;
  }
  return null;
}

String? checkConfirmPasswordValidator(String? value, String password) {
  if (value == null || value.isEmpty) {
    return AppStrings.requiredText;
  } else if (value.length < 8) {
    return AppStrings.passwordErrorText;
  } else if (password != value) {
    return AppStrings.confirmPasswordErrorText;
  }
  return null;
}
