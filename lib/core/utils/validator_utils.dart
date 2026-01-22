import 'package:presshop/core/constants/string_constants.dart';
import 'package:presshop/core/constants/regex_constants.dart';

String? checkRequiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return requiredText;
  }
  return null;
}

String? checkEmailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return requiredText;
  } else if (!emailExpression.hasMatch(value)) {
    return emailErrorText;
  }
  return null;
}

String? checkPhoneValidator(String? value) {
  if (value == null || value.isEmpty) {
    return requiredText;
  } else if (value.length < 10) {
    return phoneErrorText;
  }
  return null;
}

String? checkPasswordValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return requiredText;
  }
  return null;
}

String? checkConfirmPasswordValidator(String? value, String password) {
  if (value == null || value.isEmpty) {
    return requiredText;
  } else if (value.length < 8) {
    return passwordErrorText;
  } else if (password != value) {
    return confirmPasswordErrorText;
  }
  return null;
}
