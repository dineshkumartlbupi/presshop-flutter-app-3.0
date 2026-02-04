import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/error/exceptions.dart';

class ApiErrorHandler {
  static Failure handle(dynamic error) {
    if (error is Failure) {
      return error;
    } else if (error is DioException) {
      return _handleDioError(error);
    } else if (error is FormatException) {
      return const ServerFailure(message: "Data parsing error (Invalid JSON)");
    } else if (error is ServerException) {
      return ServerFailure(message: error.message);
    } else if (error is CacheException) {
      return CacheFailure(message: error.message);
    } else if (error is LocationException) {
      return LocationFailure(message: error.message);
    } else {
      return ServerFailure(message: error.toString());
    }
  }

  static Failure _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(message: "Connection timed out");
      case DioExceptionType.badCertificate:
        return const ServerFailure(message: "Invalid certificate");
      case DioExceptionType.badResponse:
        return _parseBadResponse(e);
      case DioExceptionType.cancel:
        return const ServerFailure(message: "Request cancelled");
      case DioExceptionType.connectionError:
        return const NetworkFailure(message: "No Internet Connection");
      case DioExceptionType.unknown:
        return const ServerFailure(message: "Something went wrong");
    }
  }

  static Failure _parseBadResponse(DioException e) {
    if (e.response?.statusCode == 502 || e.response?.statusCode == 503) {
      return _handleStatusCode(e.response?.statusCode);
    }

    try {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map &&
            data.containsKey('message') &&
            data['message'] != null) {
          String msg = data['message'];
          if (msg.contains("Cannot GET")) {
            return const ServerFailure(
                message: "Service endpoint not found (404)");
          }
          if (msg.contains("ERR_NGROK") || msg.contains("is offline")) {
            return const ServerFailure(
                message:
                    "Server is currently unavailable. Please start the server.");
          }
          return ServerFailure(message: msg);
        } else if (data is String) {
          try {
            final json = jsonDecode(data);
            if (json is Map &&
                json.containsKey('message') &&
                json['message'] != null) {
              String msg = json['message'];
              if (msg.contains("Cannot GET")) {
                return const ServerFailure(
                    message: "Service endpoint not found (404)");
              }
              return ServerFailure(message: msg);
            }
          } catch (_) {}

          if (data.toString().contains("Cannot GET")) {
            return const ServerFailure(
                message: "Service endpoint not found (404)");
          }
          if (data.toString().contains("ERR_NGROK") ||
              data.toString().contains("is offline")) {
            return const ServerFailure(
                message:
                    "Server is currently unavailable. Please start the server.");
          }

          if (data.toString().length < 100) {
            return ServerFailure(message: data.toString());
          }
        }
      }
    } catch (_) {}

    return _handleStatusCode(e.response?.statusCode);
  }

  static ServerFailure _handleStatusCode(int? statusCode) {
    if (statusCode == null) {
      return const ServerFailure(message: "Unknown server error");
    }

    switch (statusCode) {
      case 400:
        return const ServerFailure(message: "Bad request");
      case 401:
        return const ServerFailure(
            message: "Unauthorized. Please login again.");
      case 403:
        return const ServerFailure(message: "Access denied or forbidden");
      case 404:
        return const ServerFailure(message: "Resource not found (404)");
      case 409:
        return const ServerFailure(message: "Conflict occurred");
      case 422:
        return const ServerFailure(message: "Invalid input data");
      case 429:
        return const ServerFailure(message: "Too many requests. Please wait.");
      case 500:
        return const ServerFailure(message: "Internal server error");
      case 502:
        return const ServerFailure(message: "Bad Gateway. Server is down.");
      case 503:
        return const ServerFailure(
            message: "Service unavailable. Please try again later.");
      case 504:
        return const ServerFailure(message: "Gateway timeout.");
      default:
        return ServerFailure(
            message: "Received invalid status code: $statusCode");
    }
  }

  static bool isUnauthenticated(DioException e) {
    return e.response?.statusCode == 401;
  }
}
