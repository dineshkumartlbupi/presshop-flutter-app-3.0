import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:lottie/lottie.dart';
import 'package:mime/mime.dart';
import 'package:presshop/utils/CommonWigdets.dart';

import '../../main.dart';
import '../Common.dart';
import '../CommonSharedPrefrence.dart';
import 'NetworkResponse.dart';

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

  NetworkClass.fromNetworkClass(this.endUrl, this.networkResponse, this.requestCode, this.jsonBody);

  NetworkClass.fromNetworkClassRow(this.endUrl, this.networkResponse, this.requestCode, this.jsonBodyRow);

  NetworkClass.multipartSingleImageNetworkClass(this.endUrl, this.networkResponse, this.requestCode, this.jsonBody, this.filePath, this.param);

  NetworkClass.multipartNetworkClassFiles(this.endUrl, this.networkResponse, this.requestCode, this.jsonBody, this._files);

  Future<void> callMultipartService(bool showLoader, String requestType, List<String> imageParams, List<String>? mimeType) async {
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
        request.headers.addAll({headerKey: headerToken});
      }

      debugPrint("token ===>${request.headers}");
      debugPrint("url::::$url");
      if (imageParams.isNotEmpty) {
        for (int i = 0; i < imageParams.length; i++) {
          debugPrint("FilePath: ${_files![i].path}");

          if (mimeType != null) {
            var mArray = mimeType[i].split("/");

            var pic = await http.MultipartFile.fromPath(imageParams[i], _files![i].path, contentType: MediaType(mArray.first, mArray.last));
            request.files.add(pic);
          } else {
            var pic = await http.MultipartFile.fromPath(imageParams[i], _files![i].path);
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
      if (response.statusCode <= 201) {
        if (showLoader) {
          if (alertDialog != null && isShowing) {
            isShowing = false;
            Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
          }
        }

        networkResponse!.onResponse(requestCode: requestCode, response: responseString);
      } else {
        if (alertDialog != null && isShowing) {
          isShowing = false;
          Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
        }

        networkResponse!.onError(requestCode: requestCode, response: responseString);
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
  Future<dynamic> callMultipartServiceWithReturn(bool showLoader, String requestType) async {
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

      var pic = await http.MultipartFile.fromPath(param, filePath, contentType: MediaType(mArray.first, mArray.last));
      request.files.add(pic);

      if (sharedPreferences!.getString(tokenKey) != null) {
        headerToken = sharedPreferences!.getString(tokenKey)!;
        request.headers.addAll({headerKey: headerToken});
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
            Navigator.of(navigatorKey.currentState!.context, rootNavigator: true).pop();
          }
        }

        return [true, responseString];
      } else {
        if (alertDialog != null && isShowing) {
          isShowing = false;
          Navigator.of(navigatorKey.currentState!.context, rootNavigator: true).pop();
        }

        return [false, responseString];
      }
    } on SocketException catch (e) {
      if (alertDialog != null && isShowing) {
        isShowing = false;
        Navigator.of(navigatorKey.currentState!.context, rootNavigator: true).pop();
      }
      commonSocketException(e.osError!.errorCode, e.message);
      return [
        false,
        {"Error": "Socket Exception"}
      ];
    } on Exception catch (e) {
      if (alertDialog != null && isShowing) {
        isShowing = false;
        Navigator.of(navigatorKey.currentState!.context, rootNavigator: true).pop();
      }
      return [
        false,
        {"Error": e}
      ];
    }
  }

  Future<void> callRequestServiceHeader(bool showLoader, String requestType, Map<String, dynamic>? queryParameters) async {
    try {
      if (showLoader && alertDialog == null && !isShowing) {
        isShowing = true;
        showLoaderDialog(navigatorKey.currentContext!);
      }

      Uri uri;

      if (queryParameters != null) {
        debugPrint("Queryparams: $queryParameters");
        uri = Uri.parse(baseUrl + endUrl).replace(queryParameters: queryParameters);
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
        request.headers.addAll({headerKey: headerToken});
      }

      debugPrint("HeadersAre: ${request.headers}");

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse).timeout(const Duration(seconds: 20), onTimeout: () {
        if (alertDialog != null && isShowing) {
          isShowing = false;
          Navigator.of(navigatorKey.currentState!.context, rootNavigator: true).pop();
        }
        showSnackBar("Connection timeout", "Connection timeout", Colors.red);
        return http.Response("Error", 408);
      });

      debugPrint("BodyIs: ${response.body.toString()}");

      if (response.statusCode <= 201) {
        if (showLoader) {
          if (alertDialog != null && isShowing) {
            isShowing = false;
            Navigator.of(navigatorKey.currentState!.context, rootNavigator: true).pop();
          }
        }

        networkResponse!.onResponse(requestCode: requestCode, response: response.body.toString());
      } else {
        if (alertDialog != null && isShowing) {
          isShowing = false;
          Navigator.of(navigatorKey.currentState!.context, rootNavigator: true).pop();
        }

        networkResponse!.onError(requestCode: requestCode, response: response.body.toString());
      }
    } on SocketException catch (e) {
      if (alertDialog != null && isShowing) {
        isShowing = false;
        Navigator.of(navigatorKey.currentState!.context, rootNavigator: true).pop();
      }
      commonSocketException(e.osError!.errorCode, e.message);
    }
  }

  Future<void> callPatchServiceHeaderRow(BuildContext context, bool showLoader) async {
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
    final response = await http.patch(url, body: jsonEncode(jsonBodyRow), headers: {headerKey: headerToken, "Content-Type": "application/json"});

    if (response.statusCode <= 201) {
      if (showLoader) {
        if (alertDialog != null && isShowing) {
          isShowing = false;
          Navigator.pop(navigatorKey.currentContext!);
        }
      }

      networkResponse!.onResponse(requestCode: requestCode, response: response.body.toString());
    } else {
      if (alertDialog != null && isShowing) {
        isShowing = false;
        Navigator.pop(navigatorKey.currentContext!);
      }
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

          var pic = await http.MultipartFile.fromPath(keyList[i], imageParams[keyList[i]]!, contentType: MediaType(mArray.first, mArray.last));
          request.files.add(pic);
        }
      }

      if (sharedPreferences!.getString(tokenKey) != null) {
        headerToken = sharedPreferences!.getString(tokenKey)!;
        request.headers.addAll({headerKey: headerToken});
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
            Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
          }
        }

        networkResponse!.onResponse(requestCode: requestCode, response: responseString);
      } else {
        if (alertDialog != null && isShowing) {
          isShowing = false;
          Navigator.of(navigatorKey.currentState!.context, rootNavigator: true).pop();
        }

        networkResponse!.onError(requestCode: requestCode, response: responseString);
      }
    } on SocketException catch (e) {
      if (alertDialog != null && isShowing) {
        isShowing = false;
        Navigator.of(navigatorKey.currentState!.context, rootNavigator: true).pop();
      }
      commonSocketException(e.osError!.errorCode, e.message);
    }
  }

  Future<void> callMultipartServiceSameParamMultiImage(
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
          var pic = await http.MultipartFile.fromPath(imageParams, element.path, contentType: MediaType(mArray.first, mArray.last));
          request.files.add(pic);
        }
      }

      if (sharedPreferences!.getString(tokenKey) != null) {
        headerToken = sharedPreferences!.getString(tokenKey)!;
        request.headers.addAll({headerKey: headerToken});
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
            Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
          }
        }

        networkResponse!.onResponse(requestCode: requestCode, response: responseString);
      } else {
        if (alertDialog != null && isShowing) {
          isShowing = false;
          Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
        }

        networkResponse!.onError(requestCode: requestCode, response: responseString);
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

    showDialog(
      barrierColor: Colors.white.withOpacity(0),
      useSafeArea: false,
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alertDialog!;
      },
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
}
