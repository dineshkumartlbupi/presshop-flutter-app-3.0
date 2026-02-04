import 'package:dio/dio.dart';
import 'package:presshop/core/api/api_constant_new.dart';
import 'package:presshop/core/error/failures.dart';
import '../models/user_model.dart';
import 'package:presshop/core/core_export.dart';
import '../models/avatar_model.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:dartz/dartz.dart';

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
        print("🔵 LOGIN RESPONSE DATA: ${data['data']}");
        if (data['code'] == 200 || data['success'] == true) {
          final userMap = data['data'];
          if (userMap != null) {
            print(
                "****************************************************************");
            print("🔵 LOGIN RESPONSE RAW DATA: $userMap");
            print("🔵 LOGIN RESPONSE KEYS: ${userMap.keys.toList()}");
            print(
                "****************************************************************");
            // Robust token parsing
            String? accessToken = data['token'] ??
                data['access_token'] ??
                userMap['token'] ??
                userMap['access_token'];
            String? refreshToken = data['refreshToken'] ??
                data['refresh_token'] ??
                userMap['refreshToken'] ??
                userMap['refresh_token'];

            if (accessToken != null) {
              userMap['token'] = accessToken;
            }
            if (refreshToken != null) {
              userMap['refreshToken'] = refreshToken;
            }
            return UserModel.fromJson(userMap);
          } else {
            throw ServerFailure(message: "User data is null");
          }
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
      final response = await apiClient.post(
        ApiConstantsNew.auth.socialLogin,
        data: {
          "social_type": socialType,
          "social_id": socialId,
          "email": email,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print("🔵 SOCIAL LOGIN RESPONSE DATA: $data");
        if (data['code'] == 200 || data['success'] == true) {
          final userMap = data['user'] ?? data['data'];

          if (userMap != null) {
            // Robust token parsing
            String? accessToken = data['token'] ??
                data['access_token'] ??
                userMap['token'] ??
                userMap['access_token'];
            String? refreshToken = data['refreshToken'] ??
                data['refresh_token'] ??
                userMap['refreshToken'] ??
                userMap['refresh_token'];

            if (accessToken != null) {
              userMap['token'] = accessToken;
            }
            if (refreshToken != null) {
              userMap['refreshToken'] = refreshToken;
            }
            return UserModel.fromJson(userMap);
          } else {
            throw ServerFailure(message: "User data is null");
          }
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
          final userMap =
              resData['user'] ?? resData['data']; // Check API structure

          if (userMap == null) {
            throw ServerFailure(message: 'Invalid response: User data missing');
          }

          String? accessToken = resData['token'] ??
              resData['access_token'] ??
              userMap['token'] ??
              userMap['access_token'];
          String? refreshToken = resData['refreshToken'] ??
              resData['refresh_token'] ??
              userMap['refreshToken'] ??
              userMap['refresh_token'];

          if (accessToken != null) {
            userMap['token'] = accessToken;
          }
          if (refreshToken != null) {
            userMap['refreshToken'] = refreshToken;
          }
          return UserModel.fromJson(userMap);
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
        if (resData['data'] == null) {
          throw ServerFailure(message: "Profile data is empty");
        }
        return UserModel.fromJson(resData['data']);
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

        // Fallback/Legacy: Check code
        if (data['code'] != null) {
          if (data['code'] != 200) {
            // In legacy, != 200 usually meant error/taken.
            // If code is present and not 200, assume failure/taken.
            return false;
          }
        }

        return true; // Default to available if 'exists' is not true and no error code
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
        print("Phone check uttar: $data");

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
        final data = response.data;
        print("🔵 GET AVATARS RESPONSE: $data");
        // API returns: {"success": true, "data": [{"avatar": "...", ...}]}
        final List list = data['data'] ?? [];
        return list.map((e) => AvatarModel.fromJson(e)).toList();
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
        if (resData['code'] == 200) {
          final userMap = resData['user'] ?? resData['data'];

          if (userMap == null) {
            throw ServerFailure(message: 'Invalid response: User data missing');
          }

          // Robust token parsing
          String? accessToken = resData['token'] ??
              resData['access_token'] ??
              userMap['token'] ??
              userMap['access_token'];
          String? refreshToken = resData['refreshToken'] ??
              resData['refresh_token'] ??
              userMap['refreshToken'] ??
              userMap['refresh_token'];

          if (accessToken != null) {
            userMap['token'] = accessToken;
          }
          if (refreshToken != null) {
            userMap['refreshToken'] = refreshToken;
          }
          return UserModel.fromJson(userMap);
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
        print("Forgot Password Response: $data");

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
        print("Verify OTP Response: $data");

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
        print("Reset Password Response: $data");

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
