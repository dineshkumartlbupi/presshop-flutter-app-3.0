import 'package:dio/dio.dart';
import 'package:presshop/core/error/failures.dart';
import '../models/user_model.dart';
import 'package:presshop/core/core_export.dart'; // For loginUrl and auth endpoints
import '../models/avatar_model.dart';
import 'package:presshop/core/api/api_client.dart';
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
  Future<Either<Failure, bool>> forgotPassword(String email);
  Future<bool> verifyForgotPasswordOtp(String email, String otp);
  Future<bool> resetPassword(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await apiClient.post(
        loginUrl,
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
            userMap['token'] = userMap['access_token'];
            // Check for both snake_case and camelCase
            userMap['refreshToken'] =
                userMap['refresh_token'] ?? userMap['refreshToken'];
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
    } on DioException catch (e) {
      String errorMessage = e.message ?? 'Unknown error';
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      throw ServerFailure(message: errorMessage);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<UserModel> socialLogin(String socialType, String socialId,
      String email, String name, String photoUrl) async {
    try {
      final response = await apiClient.post(
        socialExistUrl,
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
          // Check for token in root or inside data object
          String? accessToken = data['token'] ??
              data['access_token'] ??
              data['data']?['token'] ??
              data['data']?['access_token'];

          String? refreshToken = data['refreshToken'] ??
              data['refresh_token'] ??
              data['data']?['refreshToken'] ??
              data['data']?['refresh_token'];

          if (accessToken != null) {
            final userMap = data['user'] ?? data['data'];

            if (userMap != null) {
              userMap['token'] = accessToken;
              userMap['refreshToken'] = refreshToken;
              return UserModel.fromJson(userMap);
            } else {
              throw ServerFailure(message: "User data is null");
            }
          } else {
            throw const UserNotRegisteredFailure(
                message: 'User not registered');
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
    } on DioException catch (e) {
      String errorMessage = e.message ?? 'Unknown error';
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      throw ServerFailure(message: errorMessage);
    } catch (e) {
      if (e is Failure) rethrow; // UserNotRegisteredFailure is a Failure
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<UserModel> register(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post(
        registerUrl,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData['code'] == 200 || resData['success'] == true) {
          final userMap =
              resData['user'] ?? resData['data']; // Check API structure

          if (userMap == null) {
            throw ServerFailure(message: 'Invalid response: User data missing');
          }

          if (resData['token'] != null) {
            userMap['token'] = resData['token'];
            userMap['refreshToken'] = resData['refreshToken'];
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
    } on DioException catch (e) {
      String errorMessage = e.message ?? 'Unknown error';
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      throw ServerFailure(message: errorMessage);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<bool> sendOtp(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post(
        sendOtpUrl,
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
    } on DioException catch (e) {
      String errorMessage = e.message ?? 'Unknown error';
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      throw ServerFailure(message: errorMessage);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<UserModel> getProfile(String userId) async {
    try {
      if (userId.isEmpty) {
        throw ServerFailure(message: "UserId is missing");
      }

      final response = await apiClient.get(
        myProfileUrl,
        queryParameters: {"userId": userId},
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
    } on DioException catch (e) {
      String errorMessage = e.message ?? 'Network error';
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      throw ServerFailure(message: errorMessage);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<bool> verifyOtp(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post(
        verifyOtpUrl,
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
    } on DioException catch (e) {
      String errorMessage = e.message ?? 'Unknown error';
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      throw ServerFailure(message: errorMessage);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<bool> checkUserName(String userName) async {
    try {
      final url = checkUserNameUrl.replaceAll(":username", userName);
      final response = await apiClient.get(url);
      if (response.statusCode == 200) {
        final data = response.data;
        // If code is 200, it means it EXISTS, so it is NOT available.
        return data['code'] != 200;
      }
      return true; // If not 200, assume available? Or check for specific 404?
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        // 404 means "Not Found", so it IS available.
        return true;
      }
      // Other errors, assume not available or throw?
      // Legacy code returned false on error.
      return false;
    }
  }

  @override
  Future<bool> checkEmail(String email) async {
    try {
      final url = checkEmailUrl.replaceAll(":email", email);
      final response = await apiClient.get(url);
      final data = response.data;
      // If code is 200, it means it EXISTS, so it is NOT available.
      return data['code'] != 200;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return true;
      }
      return false;
    }
  }

  @override
  Future<bool> checkPhone(String phone) async {
    try {
      final url = checkPhoneUrl.replaceAll(":phone", phone);
      final response = await apiClient.get(url);
      final data = response.data;
      print("Phone check uttar: $data");
      // If code is 200, it means it EXISTS, so it is NOT available.
      return data['code'] != 200;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return true;
      }
      return false;
    }
  }

  @override
  Future<List<AvatarModel>> getAvatars() async {
    try {
      final response = await apiClient.get(getAvatarsUrl);
      if (response.statusCode == 200) {
        final data = response.data;
        print("🔵 GET AVATARS RESPONSE: $data");
        // API returns: {"base_url": "...", "response": [...]}
        final String baseUrl = data['base_url'] ?? '';
        final List list = data['response'] ?? [];
        return list
            .map((e) => AvatarModel.fromJson(e, baseUrl: baseUrl))
            .toList();
      }
      return [];
    } catch (e) {
      throw ServerFailure(message: 'Failed to get avatars');
    }
  }

  @override
  Future<Map<String, dynamic>> verifyReferralCode(String code) async {
    try {
      final response =
          await apiClient.post(referralUrl, data: {"referral_code": code});
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
      final response = await apiClient.post(socialExistUrl, data: params);
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

        response = await apiClient.multipartPost(socialLoginRegisterUrl,
            formData: formData);
      } else {
        // Normal JSON request
        response = await apiClient.post(socialLoginRegisterUrl, data: data);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData['code'] == 200) {
          final userMap = resData['user'] ?? resData['data'];

          if (userMap == null) {
            throw ServerFailure(message: 'Invalid response: User data missing');
          }

          if (resData['token'] != null) {
            userMap['token'] = resData['token'];
            userMap['refreshToken'] = resData['refreshToken'];
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
    } on DioException catch (e) {
      String errorMessage = e.message ?? 'Unknown error';
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      throw ServerFailure(message: errorMessage);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<Either<Failure, bool>> forgotPassword(String email) async {
    try {
      final response = await apiClient.post(
        forgotPasswordUrl,
        data: {"email": email},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['code'] == 200) {
          return const Right(true);
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
    } on DioException catch (e) {
      String errorMessage = e.message ?? 'Network error';
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response?.data?['message'] ?? errorMessage;
      }
      return Left(ServerFailure(message: errorMessage));
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> verifyForgotPasswordOtp(String email, String otp) async {
    try {
      final response = await apiClient
          .post(verifyForgotPasswordOTPUrl, data: {"email": email, "otp": otp});
      if (response.statusCode == 200) {
        final data = response.data;
        // Check "otp_match" boolean or similar based on legacy code
        // Legacy: if (map["otp_match"]) ...
        if (data['otp_match'] == true) {
          return true;
        } else {
          throw ServerFailure(message: data['message'] ?? 'Invalid OTP');
        }
      } else {
        throw ServerFailure(
            message: 'Verify OTP failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = e.message ?? 'Unknown error';
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      throw ServerFailure(message: errorMessage);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<bool> resetPassword(String email, String password) async {
    try {
      final response = await apiClient
          .post(resetPasswordUrl, data: {"email": email, "password": password});
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200) {
          return true;
        } else {
          throw ServerFailure(
              message: data['message'] ?? 'Reset password failed');
        }
      } else {
        throw ServerFailure(
            message: 'Reset password failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = e.message ?? 'Unknown error';
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      throw ServerFailure(message: errorMessage);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(message: e.toString());
    }
  }
}
