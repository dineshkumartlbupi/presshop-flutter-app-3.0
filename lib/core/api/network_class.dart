import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:lottie/lottie.dart';
import 'package:mime/mime.dart';
import 'package:presshop/core/constants/api_constant.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/core/api/token_refresh_manager.dart';

import 'package:presshop/main.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/core/api/network_response.dart';

class NetworkClass {
  var dio = Dio();
  String endUrl = "";
  NetworkResponse? networkResponse;
  int requestCode = 0;
  Map<String, String>? jsonBody;
  Map<String, dynamic>? jsonBodyRow;
  AlertDialog? alertDialog;
  bool isShowing = false;
  String filePath = "";
  String param = "";
  List<dynamic>? imageList;
  List<File>? _files;
  List<String>? imageArray;

  NetworkClass(this.endUrl, this.networkResponse, this.requestCode);

  NetworkClass.fromNetworkClass(
      this.endUrl, this.networkResponse, this.requestCode, this.jsonBody);

  NetworkClass.fromNetworkClassRow(
      this.endUrl, this.networkResponse, this.requestCode, this.jsonBodyRow);

  NetworkClass.multipartSingleImageNetworkClass(
      this.endUrl,
      this.networkResponse,
      this.requestCode,
      this.jsonBody,
      this.filePath,
      this.param);

  NetworkClass.multipartNetworkClassFiles(this.endUrl, this.networkResponse,
      this.requestCode, this.jsonBody, this._files);

// NetworkClass.multipartNetworkClassFiles(
//   String endUrl,
//   NetworkResponse networkResponse,
//   int requestCode,
//   Map<String, String> jsonBody,
//   List<File>? files,
// ) {
//   this.endUrl = endUrl;
//   this.networkResponse = networkResponse;
//   this.requestCode = requestCode;
//   this.jsonBody = jsonBody;

//   // validate files BEFORE storing
//   if (files != null && files.isNotEmpty) {
//     this._files = files.where((f) {
//       final exists = f.existsSync();
//       if (!exists) debugPrint("⚠️ Skipping invalid file: ${f.path}");
//       return exists;
//     }).toList();
//   } else {
//     this._files = []; // keep safe
//   }
// }

  Future<void> callMultipartService(bool showLoader, String requestType,
      List<String> imageParams, List<String>? mimeType) async {
    try {
      if (showLoader && alertDialog == null && !isShowing) {
        isShowing = true;
        showLoaderDialog(navigatorKey.currentContext!);
      }
      var url = Uri.parse(baseUrl + endUrl);
      debugPrint(url.path);

      String headerToken = "";

      var request = http.MultipartRequest(requestType, url);
      if (sharedPreferences!.getString(tokenKey) != null) {
        headerToken = sharedPreferences!.getString(tokenKey)!;
        var deviceID = sharedPreferences!.getString(deviceIdKey)!;
        // Add headers
        request.headers.addAll({
          headerKey: headerToken,
          headerDeviceTypeKey:
              "mobile-flutter-${Platform.isIOS ? "ios" : "android"}",
          headerDeviceIdKey: deviceID
        });
      }

      debugPrint("token ===>${request.headers}");
      debugPrint("url::::$url");
      if (imageParams.isNotEmpty) {
        for (int i = 0; i < imageParams.length; i++) {
          debugPrint("FilePath: ${_files![i].path}");

          if (mimeType != null) {
            var mArray = mimeType[i].split("/");

            var pic = await http.MultipartFile.fromPath(
                imageParams[i], _files![i].path,
                contentType: MediaType(mArray.first, mArray.last));
            request.files.add(pic);
          } else {
            var pic = await http.MultipartFile.fromPath(
                imageParams[i], _files![i].path);
            request.files.add(pic);
          }
        }
      }

      debugPrint("Files: ${request.files}");

      /* if (sharedPreferences!.getString(tokenKey) != null) {
      headerToken = sharedPreferences!.getString(tokenKey)!;
      request.headers[headerKey] = headerToken;
      request.headers[sessionKey] = sessionValue;
    } else {
      request.headers[sessionKey] = sessionValue;
    }
*/

      if (jsonBody != null && jsonBody.toString().trim().isNotEmpty) {
        request.fields.addAll(jsonBody!);
      }

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      debugPrint("ResponseIs: ${response.statusCode}");

      // Check for 401 Unauthorized - but skip if this is the refresh token API itself
      if (TokenRefreshManager.isUnauthorizedResponse(
              response.statusCode, responseString) &&
          !endUrl.contains(appRefreshTokenUrl)) {
        debugPrint(
            "401 Unauthorized detected in multipart, attempting token refresh...");

        // Hide loader if showing
        if (alertDialog != null && isShowing) {
          isShowing = false;
          Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
        }

        // If already refreshing, wait and retry
        if (TokenRefreshManager().isRefreshing) {
          debugPrint("Token refresh in progress, waiting...");
          await Future.delayed(const Duration(milliseconds: 500));
          // Retry the request after token refresh
          TokenRefreshManager().addPendingRequest(
            () => callMultipartService(
                showLoader, requestType, imageParams, mimeType),
          );
          return;
        }

        // Attempt to refresh token
        final refreshSuccess = await TokenRefreshManager().refreshToken();

        if (refreshSuccess) {
          debugPrint(
              "Token refreshed successfully, retrying original multipart request...");
          // Retry the original request with new token
          await callMultipartService(
              showLoader, requestType, imageParams, mimeType);
          return;
        } else {
          // NEVER logout automatically - always keep user logged in
          // Token refresh failed but user stays logged in
          // Let the original request fail so user can retry manually
          debugPrint(
              "Token refresh failed, but keeping user logged in. Original request will fail - user can retry.");
          networkResponse!.onError(
              requestCode: requestCode,
              response:
                  '{"code": 401, "message": "Session expired. Please try again."}');
          return;
        }
      }

      if (response.statusCode <= 201) {
        if (showLoader) {
          if (alertDialog != null && isShowing) {
            isShowing = false;
            Navigator.of(navigatorKey.currentContext!, rootNavigator: true)
                .pop();
          }
        }

        networkResponse!
            .onResponse(requestCode: requestCode, response: responseString);
      } else {
        if (alertDialog != null && isShowing) {
          isShowing = false;
          Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
        }

        networkResponse!
            .onError(requestCode: requestCode, response: responseString);
      }
    } on SocketException catch (e) {
      if (alertDialog != null && isShowing) {
        isShowing = false;
        Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
      }
      commonSocketException(e.osError!.errorCode, e.message);
    }
  }

  /// Sidharth
  Future<dynamic> callMultipartServiceWithReturn(
      bool showLoader, String requestType) async {
    try {
      if (showLoader && alertDialog == null && !isShowing) {
        isShowing = true;
        showLoaderDialog(navigatorKey.currentContext!);
      }
      var url = Uri.parse(baseUrl + endUrl);
      debugPrint(url.path);

      String headerToken = "";

      var request = http.MultipartRequest(requestType, url);

      var mArray = lookupMimeType(filePath)!.split("/");

      var pic = await http.MultipartFile.fromPath(param, filePath,
          contentType: MediaType(mArray.first, mArray.last));
      request.files.add(pic);

      if (sharedPreferences!.getString(tokenKey) != null) {
        headerToken = sharedPreferences!.getString(tokenKey)!;
        var deviceID = sharedPreferences!.getString(deviceIdKey)!;
        // Add headers
        request.headers.addAll({
          headerKey: headerToken,
          headerDeviceTypeKey:
              "mobile-flutter-${Platform.isIOS ? "ios" : "android"}",
          headerDeviceIdKey: deviceID
        });
      }
      debugPrint("token=====> $headerToken");
      debugPrint("Filesss: ${request.files}");

      /* if (sharedPreferences!.getString(tokenKey) != null) {
      headerToken = sharedPreferences!.getString(tokenKey)!;
      request.headers[headerKey] = headerToken;
      request.headers[sessionKey] = sessionValue;
    } else {
      request.headers[sessionKey] = sessionValue;
    }
*/

      if (jsonBody != null && jsonBody.toString().trim().isNotEmpty) {
        request.fields.addAll(jsonBody!);
      }

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      debugPrint("ResponseIs: ${response.statusCode}");
      if (response.statusCode <= 201) {
        if (showLoader) {
          if (alertDialog != null && isShowing) {
            isShowing = false;
            Navigator.of(navigatorKey.currentState!.context,
                    rootNavigator: true)
                .pop();
          }
        }

        return [true, responseString];
      } else {
        if (alertDialog != null && isShowing) {
          isShowing = false;
          Navigator.of(navigatorKey.currentState!.context, rootNavigator: true)
              .pop();
        }

        return [false, responseString];
      }
    } on SocketException catch (e) {
      if (alertDialog != null && isShowing) {
        isShowing = false;
        Navigator.of(navigatorKey.currentState!.context, rootNavigator: true)
            .pop();
      }
      commonSocketException(e.osError!.errorCode, e.message);
      return [
        false,
        {"Error": "Socket Exception"}
      ];
    } on Exception catch (e) {
      if (alertDialog != null && isShowing) {
        isShowing = false;
        Navigator.of(navigatorKey.currentState!.context, rootNavigator: true)
            .pop();
      }
      return [
        false,
        {"Error": e}
      ];
    }
  }

  Future<void> callRequestServiceHeaderForRefreshToken(
      String requestType) async {
    try {
      Uri uri;

      uri = Uri.parse(baseUrl + endUrl);
      debugPrint("RequestType: $requestType");
      debugPrint("RequestUrl: $uri");
      debugPrint("Json Body : $jsonBody");
      var request = http.Request(requestType, uri);

      String refreshHeaderToken = "";

      print("refresh token called ");

      if (sharedPreferences!.getString(refreshtokenKey) != null) {
        refreshHeaderToken = sharedPreferences!.getString(refreshtokenKey)!;

        String token = sharedPreferences!.getString(tokenKey)!;

        var deviceID = sharedPreferences!.getString(deviceIdKey)!;

        print("new variable112112");
        print(token);
        print(refreshHeaderToken);
        // Add headers
        // refreshHeaderToken.isNotEmpty
        //       ? refreshHeaderToken
        //       : accessHeaderKey,

        // accessHeaderKey

        String tokenforAccess =
            refreshHeaderToken == "" ? token : "";

        print("tokenAccess123 $tokenforAccess");
        request.headers.addAll({
          refreshHeaderKey: refreshHeaderToken,
          accessHeaderKey: tokenforAccess,
          headerDeviceTypeKey:
              "mobile-flutter-${Platform.isIOS ? "ios" : "android"}",
          headerDeviceIdKey: deviceID
        });
      }

      debugPrint("HeadersAre: ${request.headers}");

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse)
          .timeout(const Duration(seconds: 20), onTimeout: () {
        if (alertDialog != null && isShowing) {
          isShowing = false;
          Navigator.of(navigatorKey.currentState!.context, rootNavigator: true)
              .pop();
        }
        showSnackBar("Connection timeout", "Connection timeout", Colors.red);
        return http.Response("Error", 408);
      });

      debugPrint("BodyIs: ${response.body.toString()}");
      if (response.statusCode <= 201) {
        networkResponse!.onResponse(
            requestCode: requestCode, response: response.body.toString());
      } else {
        if (alertDialog != null && isShowing) {
          isShowing = false;
          Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
        }

        networkResponse!.onError(
            requestCode: requestCode, response: response.body.toString());
      }
    } on SocketException catch (e) {
      if (alertDialog != null && isShowing) {
        isShowing = false;
        Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
      }
      commonSocketException(e.osError!.errorCode, e.message);
    }
  }

  Future<void> callRequestServiceHeader(
    bool showLoader,
    String requestType,
    Map<String, dynamic>? queryParameters,
  ) async {
    try {
      if (showLoader && alertDialog == null && !isShowing) {
        isShowing = true;
        showLoaderDialog(navigatorKey.currentContext!);
      }

      Uri uri;

      if (queryParameters != null) {
        debugPrint("Queryparams: $queryParameters");
        uri = Uri.parse(baseUrl + endUrl)
            .replace(queryParameters: queryParameters);
      } else {
        uri = Uri.parse(baseUrl + endUrl);
      }

      debugPrint("RequestType: $requestType");
      debugPrint("RequestUrl: $uri");
      debugPrint("Json Body : $jsonBody");

      var request = http.Request(requestType, uri);

      if (requestType != "get") {
        if (jsonBody != null) {
          request.bodyFields = jsonBody!;
        }
      }
      String headerToken = "";

      if (sharedPreferences!.getString(tokenKey) != null) {
        headerToken = sharedPreferences!.getString(tokenKey)!;
        var deviceID = sharedPreferences!.getString(deviceIdKey)!;
        // Add headers
        request.headers.addAll({
          headerKey: headerToken,
          headerDeviceTypeKey:
              "mobile-flutter-${Platform.isIOS ? "ios" : "android"}",
          headerDeviceIdKey: deviceID
        });
      }

      debugPrint("HeadersAre: ${request.headers}");

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse)
          .timeout(const Duration(seconds: 20), onTimeout: () {
        if (alertDialog != null && isShowing) {
          isShowing = false;
          Navigator.of(navigatorKey.currentState!.context, rootNavigator: true)
              .pop();
        }
        showSnackBar("Connection timeout", "Connection timeout", Colors.red);
        return http.Response("Error", 408);
      });

      debugPrint("BodyIs: ${response.body.toString()}");

      // Check for 401 Unauthorized - but skip if this is the refresh token API itself
      if (TokenRefreshManager.isUnauthorizedResponse(
              response.statusCode, response.body.toString()) &&
          !endUrl.contains(appRefreshTokenUrl)) {
        debugPrint("401 Unauthorized detected, attempting token refresh...");

        // Hide loader if showing
        if (alertDialog != null && isShowing) {
          isShowing = false;
          Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
        }

        // If already refreshing, wait and retry
        if (TokenRefreshManager().isRefreshing) {
          debugPrint("Token refresh in progress, waiting...");
          await Future.delayed(const Duration(milliseconds: 500));
          // Retry the request after token refresh
          TokenRefreshManager().addPendingRequest(
            () => callRequestServiceHeader(
                showLoader, requestType, queryParameters),
          );
          return;
        }

        // Attempt to refresh token
        final refreshSuccess = await TokenRefreshManager().refreshToken();

        if (refreshSuccess) {
          debugPrint(
              "Token refreshed successfully, retrying original request...");
          // Retry the original request with new token
          await callRequestServiceHeader(
              showLoader, requestType, queryParameters);
          return;
        } else {
          // NEVER logout automatically - always keep user logged in
          // Token refresh failed but user stays logged in
          // Let the original request fail so user can retry manually
          debugPrint(
              "Token refresh failed, but keeping user logged in. Original request will fail - user can retry.");
          networkResponse!.onError(
              requestCode: requestCode,
              response:
                  '{"code": 401, "message": "Session expired. Please try again."}');
          return;
        }
      }

      if (response.statusCode <= 201) {
        if (showLoader) {
          if (alertDialog != null && isShowing) {
            isShowing = false;
            Navigator.of(navigatorKey.currentState!.context,
                    rootNavigator: true)
                .pop();
          }
        }

        networkResponse!.onResponse(
            requestCode: requestCode, response: response.body.toString());
      } else {
        if (alertDialog != null && isShowing) {
          isShowing = false;
          Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
        }

        networkResponse!.onError(
            requestCode: requestCode, response: response.body.toString());
      }
    } on SocketException catch (e) {
      if (alertDialog != null && isShowing) {
        isShowing = false;
        Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
      }
      commonSocketException(e.osError!.errorCode, e.message);
    }
  }

  Future<void> callPatchServiceHeaderRow(
      BuildContext context, bool showLoader) async {
    if (showLoader && alertDialog == null && !isShowing) {
      isShowing = true;
      showLoaderDialog(context);
    }

    String headerToken = "";

    if (sharedPreferences!.getString(tokenKey) != null) {
      headerToken = sharedPreferences!.getString(tokenKey)!;
      debugPrint("Token: $headerToken");
    }

    debugPrint("RowParams: ${jsonEncode(jsonBodyRow)}");
    var url = Uri.parse(baseUrl + endUrl);
    debugPrint("UrlIs: $url");
    final response = await http.patch(url,
        body: jsonEncode(jsonBodyRow),
        headers: {headerKey: headerToken, "Content-Type": "application/json"});

    // Check for 401 Unauthorized - but skip if this is the refresh token API itself
    if (TokenRefreshManager.isUnauthorizedResponse(
            response.statusCode, response.body.toString()) &&
        !endUrl.contains(appRefreshTokenUrl)) {
      debugPrint(
          "401 Unauthorized detected in patch, attempting token refresh...");

      // Hide loader if showing
      if (alertDialog != null && isShowing) {
        isShowing = false;
        Navigator.pop(navigatorKey.currentContext!);
      }

      // If already refreshing, wait and retry
      if (TokenRefreshManager().isRefreshing) {
        debugPrint("Token refresh in progress, waiting...");
        await Future.delayed(const Duration(milliseconds: 500));
        // Retry the request after token refresh
        TokenRefreshManager().addPendingRequest(
          () => callPatchServiceHeaderRow(context, showLoader),
        );
        return;
      }

      // Attempt to refresh token
      final refreshSuccess = await TokenRefreshManager().refreshToken();

      if (refreshSuccess) {
        debugPrint(
            "Token refreshed successfully, retrying original patch request...");
        // Retry the original request with new token
        await callPatchServiceHeaderRow(context, showLoader);
        return;
      } else {
        debugPrint("Token refresh failed, user will be logged out");
        // Check if logout is needed and navigate
        if (TokenRefreshManager.shouldLogout()) {
          _handleLogout();
        }
        return;
      }
    }

    if (response.statusCode <= 201) {
      if (showLoader) {
        if (alertDialog != null && isShowing) {
          isShowing = false;
          Navigator.pop(navigatorKey.currentContext!);
        }
      }

      networkResponse!.onResponse(
          requestCode: requestCode, response: response.body.toString());
    } else {
      if (alertDialog != null && isShowing) {
        isShowing = false;
        Navigator.pop(navigatorKey.currentContext!);
      }

      networkResponse!.onError(
          requestCode: requestCode, response: response.body.toString());
    }
  }

  Future<void> callMultipartServiceNew(
    bool showLoader,
    String requestType,
    Map<String, String> imageParams,
  ) async {
    try {
      if (showLoader && alertDialog == null && !isShowing) {
        isShowing = true;
        showLoaderDialog(navigatorKey.currentContext!);
      }
      var url = Uri.parse(baseUrl + endUrl);
      debugPrint(url.path);

      String headerToken = "";

      var request = http.MultipartRequest(requestType, url);

      if (imageParams.isNotEmpty) {
        List<String> keyList = imageParams.keys.map((e) => e).toList();

        for (int i = 0; i < keyList.length; i++) {
          debugPrint("FileKey: ${keyList[i].toString()}");
          debugPrint("FilePath: ${imageParams[keyList[i]]!}");
          var mArray = lookupMimeType(imageParams[keyList[i]]!)!.split("/");
          debugPrint("mArray: ${mArray.first}");

          var pic = await http.MultipartFile.fromPath(
              keyList[i], imageParams[keyList[i]]!,
              contentType: MediaType(mArray.first, mArray.last));
          request.files.add(pic);
        }
      }

      if (sharedPreferences!.getString(tokenKey) != null) {
        headerToken = sharedPreferences!.getString(tokenKey)!;
        var deviceID = sharedPreferences!.getString(deviceIdKey)!;
        // Add headers
        request.headers.addAll({
          headerKey: headerToken,
          headerDeviceTypeKey:
              "mobile-flutter-${Platform.isIOS ? "ios" : "android"}",
          headerDeviceIdKey: deviceID
        });
      }

      debugPrint("Files::: ${request.files}");

      debugPrint("Json data : ${jsonBody!}");

      if (jsonBody != null && jsonBody.toString().trim().isNotEmpty) {
        request.fields.addAll(jsonBody!);
      }

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      debugPrint("ResponseIs: ${response.statusCode}");
      debugPrint("ResponseIs: $responseString");
      if (response.statusCode <= 201) {
        if (showLoader) {
          if (alertDialog != null && isShowing) {
            isShowing = false;
            Navigator.of(navigatorKey.currentContext!, rootNavigator: true)
                .pop();
          }
        }

        networkResponse!
            .onResponse(requestCode: requestCode, response: responseString);
      } else {
        if (alertDialog != null && isShowing) {
          isShowing = false;
          Navigator.of(navigatorKey.currentState!.context, rootNavigator: true)
              .pop();
        }

        networkResponse!
            .onError(requestCode: requestCode, response: responseString);
      }
    } on SocketException catch (e) {
      if (alertDialog != null && isShowing) {
        isShowing = false;
        Navigator.of(navigatorKey.currentState!.context, rootNavigator: true)
            .pop();
      }
      commonSocketException(e.osError!.errorCode, e.message);
    }
  }

  Future<void> callMultipartServiceSameParamMultiImage(
    bool showLoader,
    String requestType,
    String imageParams, {
    Function(int sent, int total)? onProgress,
  }) async {
    if (showLoader && alertDialog == null && !isShowing) {
      isShowing = true;
      showLoaderDialog(navigatorKey.currentContext!);
    }
    var url = baseUrl + endUrl;
    Dio dio = Dio();
    dio.options.connectTimeout = const Duration(minutes: 5);
    dio.options.receiveTimeout = const Duration(minutes: 5);
    FormData formData = FormData();
    if (imageParams.isNotEmpty) {
      for (var element in _files!) {
        var mArray = lookupMimeType(element.path)!.split("/");
        var file = await MultipartFile.fromFile(
          element.path,
          contentType: MediaType(mArray.first, mArray.last),
        );
        formData.files.add(MapEntry(imageParams, file));
      }
    }

    if (sharedPreferences!.getString(tokenKey) != null) {
      var headerToken = sharedPreferences!.getString(tokenKey)!;
      var deviceID = sharedPreferences!.getString(deviceIdKey)!;
      dio.options.headers = {
        "Authorization": "Bearer $headerToken",
        //headerKey: headerToken,
        headerDeviceTypeKey:
            "mobile-flutter-${Platform.isIOS ? "ios" : "android"}",
        headerDeviceIdKey: deviceID
      };
    }
    if (jsonBody != null && jsonBody!.isNotEmpty) {
      jsonBody!.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
    }
    try {
      Response response = await dio.post(
        url,
        data: formData,
        onSendProgress: onProgress,
      );

      // Check for 401 Unauthorized - but skip if this is the refresh token API itself
      if (TokenRefreshManager.isUnauthorizedResponse(
              response.statusCode ?? 0, jsonEncode(response.data)) &&
          !endUrl.contains(appRefreshTokenUrl)) {
        debugPrint(
            "401 Unauthorized detected in Dio multipart, attempting token refresh...");

        // Hide loader if showing
        if (alertDialog != null && isShowing) {
          isShowing = false;
          Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
        }

        // If already refreshing, wait and retry
        if (TokenRefreshManager().isRefreshing) {
          debugPrint("Token refresh in progress, waiting...");
          await Future.delayed(const Duration(milliseconds: 500));
          // Retry the request after token refresh
          TokenRefreshManager().addPendingRequest(
            () => callMultipartServiceSameParamMultiImage(
                showLoader, requestType, imageParams),
          );
          return;
        }

        // Attempt to refresh token
        final refreshSuccess = await TokenRefreshManager().refreshToken();

        if (refreshSuccess) {
          debugPrint(
              "Token refreshed successfully, retrying original Dio multipart request...");
          // Retry the original request with new token
          await callMultipartServiceSameParamMultiImage(
              showLoader, requestType, imageParams);
          return;
        } else {
          // NEVER logout automatically - always keep user logged in
          // Token refresh failed but user stays logged in
          // Let the original request fail so user can retry manually
          debugPrint(
              "Token refresh failed, but keeping user logged in. Original request will fail - user can retry.");
          networkResponse!.onError(
              requestCode: requestCode,
              response:
                  '{"code": 401, "message": "Session expired. Please try again."}');
          return;
        }
      }

      if (showLoader) {
        if (alertDialog != null && isShowing) {
          isShowing = false;
          Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
        }
      }

      if (response.statusCode! <= 201) {
        networkResponse!.onResponse(
            requestCode: requestCode, response: jsonEncode(response.data));
      } else {
        networkResponse!.onError(
            requestCode: requestCode, response: jsonEncode(response.data));
      }
    } on SocketException catch (e) {
      if (alertDialog != null && isShowing) {
        isShowing = false;
        Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
      }
      commonSocketException(e.osError!.errorCode, e.message);
      return;
    } on DioException catch (e) {
      if (alertDialog != null && isShowing) {
        isShowing = false;
        Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
      }
      if (e.response != null) {
        networkResponse!.onError(
            requestCode: requestCode, response: jsonEncode(e.response!.data));
      } else {
        networkResponse!.onError(
            requestCode: requestCode, response: '{"message": "${e.message}"}');
      }
    }
  }

  Future<void> callMultipartServiceSameParamMultiImage1(
    bool showLoader,
    String requestType,
    String imageParams,
  ) async {
    try {
      if (showLoader && alertDialog == null && !isShowing) {
        isShowing = true;
        showLoaderDialog(navigatorKey.currentContext!);
      }
      var url = Uri.parse(baseUrl + endUrl);
      debugPrint(url.path);

      String headerToken = "";

      var request = http.MultipartRequest(requestType, url);
      if (imageParams.isNotEmpty) {
        for (var element in _files!) {
          print("MediaPath -> ${element.path}");
          var mArray = lookupMimeType(element.path)!.split("/");
          var pic = await http.MultipartFile.fromPath(imageParams, element.path,
              contentType: MediaType(mArray.first, mArray.last));
          request.files.add(pic);
        }
      }

      if (sharedPreferences!.getString(tokenKey) != null) {
        headerToken = sharedPreferences!.getString(tokenKey)!;
        var deviceID = sharedPreferences!.getString(deviceIdKey)!;
        request.headers.addAll({
          headerKey: headerToken,
          headerDeviceTypeKey:
              "mobile-flutter-${Platform.isIOS ? "ios" : "android"}",
          headerDeviceIdKey: deviceID
        });
      }

      debugPrint("Files::: ${request.files}");

      debugPrint("Json data : ${jsonBody!}");

      if (jsonBody != null && jsonBody.toString().trim().isNotEmpty) {
        request.fields.addAll(jsonBody!);
      }

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      debugPrint("ResponseIs: ${response.statusCode}");
      debugPrint("ResponseIs: $responseString");

      // Check for 401 Unauthorized - but skip if this is the refresh token API itself
      if (TokenRefreshManager.isUnauthorizedResponse(
              response.statusCode, responseString) &&
          !endUrl.contains(appRefreshTokenUrl)) {
        debugPrint(
            "401 Unauthorized detected in callMultipartServiceSameParamMultiImage1, attempting token refresh...");

        // Hide loader if showing
        if (alertDialog != null && isShowing) {
          isShowing = false;
          Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
        }

        // If already refreshing, wait and retry
        if (TokenRefreshManager().isRefreshing) {
          debugPrint("Token refresh in progress, waiting...");
          await Future.delayed(const Duration(milliseconds: 500));
          // Retry the request after token refresh
          TokenRefreshManager().addPendingRequest(
            () => callMultipartServiceSameParamMultiImage1(
                showLoader, requestType, imageParams),
          );
          return;
        }

        // Attempt to refresh token
        final refreshSuccess = await TokenRefreshManager().refreshToken();

        if (refreshSuccess) {
          debugPrint(
              "Token refreshed successfully, retrying original multipart request...");
          // Retry the original request with new token
          await callMultipartServiceSameParamMultiImage1(
              showLoader, requestType, imageParams);
          return;
        } else {
          // NEVER logout automatically - always keep user logged in
          // Token refresh failed but user stays logged in
          // Let the original request fail so user can retry manually
          debugPrint(
              "Token refresh failed, but keeping user logged in. Original request will fail - user can retry.");
          networkResponse!.onError(
              requestCode: requestCode,
              response:
                  '{"code": 401, "message": "Session expired. Please try again."}');
          return;
        }
      }

      if (response.statusCode <= 201) {
        if (showLoader) {
          if (alertDialog != null && isShowing) {
            isShowing = false;
            Navigator.of(navigatorKey.currentContext!, rootNavigator: true)
                .pop();
          }
        }

        networkResponse!
            .onResponse(requestCode: requestCode, response: responseString);
      } else {
        if (alertDialog != null && isShowing) {
          isShowing = false;
          Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
        }

        networkResponse!
            .onError(requestCode: requestCode, response: responseString);
      }
    } on SocketException catch (e) {
      if (alertDialog != null && isShowing) {
        isShowing = false;
        Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
      }
      commonSocketException(e.osError!.errorCode, e.message);
    }
  }

/*   showLoaderDialog(BuildContext context) {
    if (alertDialog != null) {
      isShowing = false;
      Navigator.of(context, rootNavigator: true).pop();
    }

    alertDialog = AlertDialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.all(0),
      actionsPadding: const EdgeInsets.all(0),
      buttonPadding: const EdgeInsets.all(0),
      titlePadding: const EdgeInsets.all(0),
      content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: const SpinKitSpinningLines(
            color: colorThemePink,
          )),
    );

  
    );
  }*/
  showLoaderDialog(BuildContext context) {
    if (alertDialog != null) {
      debugPrint("loader False:");
      isShowing = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
    alertDialog = AlertDialog(
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(0),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            "assets/lottieFiles/loader_new.json",
            height: 100,
            width: 100,
          )
          /*CircularProgressIndicator(
          color: colorThemePink,
        ),*/
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      barrierColor: Colors.white.withOpacity(0),
      context: context,
      builder: (BuildContext context) {
        return alertDialog!;
      },
    );
  }

  void commonSocketException(int errorCode, String errorMessage) {
    switch (errorCode) {
      case 7:
        debugPrint("Internet Connection Error");
        showSnackBar("Error", "Internet Connection Error", Colors.red);
        break;

      case 8:
        showSnackBar("Error", "Internet Connection Error", Colors.red);
        debugPrint("Internet Connection Error");
        break;

      case 111:
        debugPrint("Unable to connect Server");
        showSnackBar("Error", "Unable to connect to Server", Colors.red);
        break;

      default:
        debugPrint("Unknown Error :$errorMessage");
        showSnackBar("Error", "Unknown Error", Colors.red);
    }
  }

  /// Handle user logout when token refresh fails
  /// NOTE: This method is kept for reference but should NEVER be called automatically
  /// Users should only be logged out through explicit user action (logout button)
  void _handleLogout() {
    // This method should not be called automatically
    // Only manual logout should navigate to login screen
    debugPrint(
        "WARNING: _handleLogout() called - this should only happen on manual logout");
    TokenRefreshManager.clearLogoutFlag();
  }
}

/// Helper class for pending requests
class _PendingRequest {
  final Future<void> Function() retryFunction;
  final VoidCallback? onCancel;

  _PendingRequest({
    required this.retryFunction, this.onCancel,
  });

  void retry() {
    try {
      retryFunction();
    } catch (e) {
      debugPrint("Error retrying request: $e");
    }
  }

  void cancel() {
    try {
      onCancel?.call();
    } catch (e) {
      debugPrint("Error cancelling request: $e");
    }
  }
}
