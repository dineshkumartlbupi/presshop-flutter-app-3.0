import 'package:dio/dio.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/core/error/failures.dart';
import '../models/user_model.dart';
import 'package:presshop/core/core_export.dart';
import '../models/avatar_model.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';



abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
  Future<UserModel> socialLogin(String socialType, String socialId,
      String email, String name, String photoUrl);
  Future<UserModel> register(Map<String, dynamic> data);

  Future<bool> sendOtp(Map<String, dynamic> data);
  Future<UserModel> getProfile(String userId);
  Future<bool> verifyOtp(Map<String, dynamic> data);
  Future<UserModel> socialRegister(Map<String, dynamic> data);
  Future<bool> checkUserName(String userName);
  Future<bool> checkEmail(String email);
  Future<bool> checkPhone(String phone);
  Future<List<AvatarModel>> getAvatars();
  Future<Map<String, dynamic>> verifyReferralCode(String code);
  Future<bool> socialExists(Map<String, dynamic> params);
  Future<Either<Failure, String>> forgotPassword(String email);
  Future<bool> verifyForgotPasswordOtp(String email, String otp);
  Future<bool> resetPassword(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this.apiClient);
  final ApiClient apiClient;

  UserModel _handleUserResponse(dynamic responseData) {
    if (responseData is! Map<String, dynamic>) {
      throw ServerFailure(message: "Invalid response format");
    }

    Map<String, dynamic>? userMap;

    // First check nested data structure
    if (responseData['data'] != null && responseData['data'] is Map) {
      final nestedData = responseData['data'] as Map<String, dynamic>;
      userMap = (nestedData['user'] is Map)
          ? nestedData['user']
          : (nestedData['admin'] is Map ? nestedData['admin'] : nestedData);
    } else {
      userMap = (responseData['user'] is Map)
          ? responseData['user']
          : (responseData['admin'] is Map ? responseData['admin'] : null);

      // If still null, maybe it is a flat structure
      userMap ??= responseData;
    }

    if (userMap == null) {
      throw ServerFailure(message: "User data not found in response");
    }

    // Robust token parsing
    String? accessToken = responseData['token'] ??
        responseData['access_token'] ??
        userMap['token'] ??
        userMap['access_token'];
    String? refreshToken = responseData['refreshToken'] ??
        responseData['refresh_token'] ??
        userMap['refreshToken'] ??
        userMap['refresh_token'];

    // Create a mutable copy and inject tokens
    final finalUserMap = Map<String, dynamic>.from(userMap);
    if (accessToken != null) finalUserMap['token'] = accessToken;
    if (refreshToken != null) finalUserMap['refreshToken'] = refreshToken;

    return UserModel.fromJson(finalUserMap);
  }

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await apiClient.post(
        ApiConstantsNew.auth.login,
        data: {
          "userNameOrPhone": username,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200 || data['success'] == true) {
          return _handleUserResponse(data);
        } else {
          throw ServerFailure(message: data['message'] ?? 'Login failed');
        }
      } else {
        throw ServerFailure(
            message: 'Login failed with status code ${response.statusCode}');
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<UserModel> socialLogin(String socialType, String socialId,
      String email, String name, String photoUrl) async {
    try {
      debugPrint("DEBUG: [AuthRemoteDataSource] socialLogin - Start");
      debugPrint("DEBUG: socialType: $socialType, email: $email");

      final response = await apiClient.post(
        ApiConstantsNew.auth.socialLogin,
        data: {
          "social_type": socialType,
          "social_id": socialId,
          "email": email,
        },
      );

      debugPrint(
          "DEBUG: [AuthRemoteDataSource] response status: ${response.statusCode}");
      debugPrint("DEBUG: [AuthRemoteDataSource] response data: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        // Check for specific error flags in 200 OK response (some APIs do this)
        final isFailure = data['success'] == false || (data['code'] != null && data['code'] != 200);
        final message = data['message']?.toString().toLowerCase() ?? "";
        final dataStr = data.toString().toLowerCase();

        if (isFailure || message.contains("not found") || message.contains("not register") || dataStr.contains("no hopper record")) {
           if (message.contains("not found") || 
               message.contains("not register") || 
               message.contains("signup required") ||
               message.contains("no user") ||
               dataStr.contains("no hopper record") ||
               data['code'] == 404) {
             debugPrint("DEBUG: Detected new user from 200 response via message/code");
             throw const UserNotRegisteredFailure(message: "User not found, registration required");
           }
        }

        if (data['code'] == 200 || data['success'] == true) {
          final user = _handleUserResponse(data);

          // Check if it's an existing user but hasn't completed registration
          final source = user.source;
          if (source is Map<String, dynamic> && 
              (source['isSocialRegister'] == false || source['isSocialRegister']?.toString().toLowerCase() == 'false')) {
            debugPrint("DEBUG: Detected existing user with incomplete social register");
            throw const UserNotRegisteredFailure(
                message: "Social registration required");
          }
          return user;
        } else {
          throw ServerFailure(
              message: data['message'] ?? 'Social Login failed');
        }
      } else {
        throw ServerFailure(
            message:
                'Social Login failed with status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("DEBUG: [AuthRemoteDataSource] socialLogin catch error: $e");
      
      if (e is DioException) {
        final data = e.response?.data;
        final statusCode = e.response?.statusCode;
        debugPrint("DEBUG: DioException StatusCode: $statusCode");
        debugPrint("DEBUG: DioException ResponseData: $data");

        final message = (data is Map ? data['message'] : data)?.toString().toLowerCase() ?? "";
        final dataStr = data.toString().toLowerCase();
        
        if (statusCode == 404 || 
            statusCode == 400 || 
            statusCode == 401 ||
            message.contains("not found") || 
            message.contains("not register") ||
            message.contains("signup required") ||
            dataStr.contains("no hopper record")) {
          debugPrint("DEBUG: Detected new user from DioException (message: $message)");
          throw const UserNotRegisteredFailure(
              message: "User not found, registration required");
        }
      }
      
      if (e is Failure) rethrow;
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<UserModel> register(Map<String, dynamic> data) async {
    try {
      String? imagePath;
      if (data.containsKey('_imagePath')) {
        imagePath = data['_imagePath'];
        data.remove('_imagePath');
      }

      Response response;
      if (imagePath != null && imagePath.isNotEmpty) {
        // Multipart request
        FormData formData = FormData.fromMap(data);
        formData.files.add(MapEntry(
          "profile_image",
          await MultipartFile.fromFile(imagePath),
        ));

        response = await apiClient.multipartPost(
          ApiConstantsNew.auth.register,
          formData: formData,
        );
      } else {
        response = await apiClient.post(
          ApiConstantsNew.auth.register,
          data: data,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData['code'] == 200 || resData['success'] == true) {
          return _handleUserResponse(resData);
        } else {
          throw ServerFailure(
              message: resData['message'] ?? 'Registration failed');
        }
      } else {
        throw ServerFailure(
            message:
                'Registration failed with status code ${response.statusCode}');
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<bool> sendOtp(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post(
        ApiConstantsNew.auth.sendOtp,
        data: data,
      );

      if (response.statusCode == 200) {
        final resData = response.data;
        // Some APIs return 'code', some 'status'. Checking both or just 200 OK.
        if (resData['code'] == 200 ||
            resData['status'] == 200 ||
            resData['success'] == true) {
          return true;
        } else {
          throw ServerFailure(
              message: resData['message'] ?? 'Sending OTP failed');
        }
      } else {
        throw ServerFailure(
            message: 'Sending OTP failed: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<UserModel> getProfile(String userId) async {
    try {
      if (userId.isEmpty) {
        throw ServerFailure(message: "UserId is missing");
      }

      final response = await apiClient.get(
        ApiConstantsNew.profile.myProfile,
        queryParameters: {"userId": userId},
        showLoader: false,
      );

      final resData = response.data;

      if (response.statusCode == 200 && resData['success'] == true) {
        return _handleUserResponse(resData);
      } else {
        throw ServerFailure(
          message: resData['message'] ?? 'Failed to load profile',
        );
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<bool> verifyOtp(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post(
        ApiConstantsNew.auth.verifyOtp,
        data: data,
      );

      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData['code'] == 200 || resData['success'] == true) {
          return true;
        } else {
          throw ServerFailure(
              message: resData['message'] ?? 'OTP Verification failed');
        }
      } else {
        throw ServerFailure(
            message: 'OTP Verification failed: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<bool> checkUserName(String userName) async {
    try {
      final url =
          ApiConstantsNew.auth.checkUserName.replaceAll(":username", userName);
      final response = await apiClient.get(url, showLoader: false);
      if (response.statusCode == 200) {
        final data = response.data;

        // New Logic: Check for nested 'exists' key
        if (data['data'] != null && data['data'] is Map) {
          if (data['data']['exists'] == true) {
            throw ServerFailure(
                message: data['message'] ?? "Username is taken");
          }
        }

        if (data['code'] != null) {
          if (data['code'] != 200) {
            return false;
          }
        }

        return true;
      } else {
        throw ServerFailure(
            message: 'Check UserName failed: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<bool> checkEmail(String email) async {
    try {
      final url = ApiConstantsNew.auth.checkEmail.replaceAll(":email", email);
      final response = await apiClient.get(url, showLoader: false);
      if (response.statusCode == 200) {
        final data = response.data;

        // New Logic: Check for nested 'exists' key
        if (data['data'] != null && data['data'] is Map) {
          if (data['data']['exists'] == true) {
            return false; // User exists, so NOT available
          }
        }

        // Fallback/Legacy: Check code
        if (data['code'] != null) {
          return data['code'] != 200;
        }

        return true;
      } else {
        throw ServerFailure(
            message: 'Check Email failed: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<bool> checkPhone(String phone) async {
    try {
      final url = ApiConstantsNew.auth.checkPhone.replaceAll(":phone", phone);
      final response = await apiClient.get(url, showLoader: false);
      if (response.statusCode == 200) {
        final data = response.data;

        // New Logic: Check for nested 'exists' key
        if (data['data'] != null && data['data'] is Map) {
          if (data['data']['exists'] == true) {
            throw ServerFailure(
                message: data['message'] ?? "Phone number is already taken");
          }
        }

        // Fallback/Legacy: Check code
        if (data['code'] != null) {
          if (data['code'] != 200) {
            return false;
          }
        }

        return true;
      } else {
        throw ServerFailure(
            message: 'Check Phone failed: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<AvatarModel>> getAvatars() async {
    try {
      final response = await apiClient.get(ApiConstantsNew.profile.getAvatars);
      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        List list = [];
        if (responseData is Map) {
          list = (responseData['data'] ?? responseData['status'] ?? []) as List;
        } else if (responseData is List) {
          list = responseData;
        }
        return list.map((e) {
          if (e is Map<String, dynamic>) {
            return AvatarModel.fromJson(e);
          } else {
            return AvatarModel(id: '', avatar: e.toString());
          }
        }).toList();
      }
      return [];
    } catch (e) {
      throw ServerFailure(message: 'Failed to get avatars');
    }
  }

  @override
  Future<Map<String, dynamic>> verifyReferralCode(String code) async {
    try {
      final response = await apiClient.post(ApiConstantsNew.auth.verifyReferral,
          data: {"referral_code": code});
      if (response.statusCode == 200) {
        return response.data;
      }
      throw ServerFailure(
          message: 'Referral code verification failed: ${response.statusCode}');
    } catch (e) {
      throw ServerFailure(message: 'Referral code verification failed');
    }
  }

  @override
  Future<bool> socialExists(Map<String, dynamic> params) async {
    try {
      final response =
          await apiClient.post(ApiConstantsNew.auth.socialLogin, data: params);
      final data = response.data;
      if (data['code'] == 200 && data['token'] != null) {
        final userMap = data['data'] ?? data['user'];
        if (userMap != null && userMap['isSocialRegister'] == false) {
          return false;
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserModel> socialRegister(Map<String, dynamic> data) async {
    try {
      String? imagePath;
      if (data.containsKey('_imagePath')) {
        imagePath = data['_imagePath'];
        data.remove('_imagePath');
      }

      Response response;
      if (imagePath != null && imagePath.isNotEmpty) {
        // Multipart request
        FormData formData = FormData.fromMap(data);
        formData.files.add(MapEntry(
          "profile_image",
          await MultipartFile.fromFile(imagePath),
        ));

        response = await apiClient.multipartPost(
            ApiConstantsNew.auth.socialRegister,
            formData: formData);
      } else {
        // Normal JSON request
        response = await apiClient.post(ApiConstantsNew.auth.socialRegister,
            data: data);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData['code'] == 200 || resData['success'] == true) {
          return _handleUserResponse(resData);
        } else {
          throw ServerFailure(
              message: resData['message'] ?? 'Social Registration failed');
        }
      } else {
        throw ServerFailure(
            message: 'Social Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<Either<Failure, String>> forgotPassword(String email) async {
    try {
      final response = await apiClient.post(
        ApiConstantsNew.auth.forgotPassword,
        data: {"email": email},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Structure check:
        // { "success": true, "message": "...", "data": { "code": 200, "data": "OTP" } }

        // Check top-level success
        bool isSuccess = data['success'] == true;

        // Check nested code if available
        if (data['data'] != null && data['data'] is Map) {
          final nestedData = data['data'];
          if (nestedData['code'] == 200) {
            isSuccess = true;
          }
        } else if (data['code'] == 200) {
          isSuccess = true;
        }

        if (isSuccess) {
          // Attempt to extract OTP
          String otp = "";

          if (data['data'] != null) {
            if (data['data'] is Map) {
              // Nested case: data['data']['data']
              if (data['data']['data'] != null) {
                otp = data['data']['data'].toString();
              }
            } else {
              // Flat case (legacy fallback): data['data']
              otp = data['data'].toString();
            }
          }

          return Right(otp);
        } else {
          return Left(ServerFailure(
            message: data['message'] ?? 'Forgot password failed',
          ));
        }
      } else {
        return Left(ServerFailure(
          message: 'Forgot password failed: ${response.statusCode}',
        ));
      }
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<bool> verifyForgotPasswordOtp(String email, String otp) async {
    try {
      final response = await apiClient.post(
          ApiConstantsNew.auth.verifyForgotOtp,
          data: {"email": email, "otp": otp});
      if (response.statusCode == 200) {
        final data = response.data;

        bool otpMatch = false;

        if (data['otp_match'] == true) {
          otpMatch = true;
        } else if (data['data'] != null && data['data'] is Map) {
          if (data['data']['otp_match'] == true) {
            otpMatch = true;
          }
        }

        if (otpMatch) {
          return true;
        } else {
          throw ServerFailure(message: data['message'] ?? 'Invalid OTP');
        }
      } else {
        throw ServerFailure(
            message: 'Verify OTP failed: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<bool> resetPassword(String email, String password) async {
    try {
      final response = await apiClient.post(ApiConstantsNew.auth.resetPassword,
          data: {"email": email, "password": password});
      if (response.statusCode == 200) {
        final data = response.data;

        bool isSuccess = false;

        // Check top-level code or success
        if (data['code'] == 200 || data['success'] == true) {
          isSuccess = true;
        }

        // Check nested code if not found yet
        if (!isSuccess && data['data'] != null && data['data'] is Map) {
          if (data['data']['code'] == 200) {
            isSuccess = true;
          }
        }

        if (isSuccess) {
          return true;
        } else {
          throw ServerFailure(
              message: data['message'] ?? 'Reset password failed');
        }
      } else {
        throw ServerFailure(
            message: 'Reset password failed: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
