import 'package:dio/dio.dart';
import 'package:presshop/core/error/failures.dart';
import '../models/user_model.dart';
import 'package:presshop/core/core_export.dart'; // For loginUrl and auth endpoints
import '../models/avatar_model.dart';
import 'package:presshop/core/api/api_client.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
  Future<UserModel> socialLogin(String socialType, String socialId, String email, String name, String photoUrl);
  Future<UserModel> register(Map<String, dynamic> data);

  Future<bool> sendOtp(Map<String, dynamic> data);
  Future<UserModel> getProfile();
  Future<bool> verifyOtp(Map<String, dynamic> data); 
  Future<UserModel> socialRegister(Map<String, dynamic> data);
  Future<bool> checkUserName(String userName);
  Future<bool> checkEmail(String email);
  Future<bool> checkPhone(String phone);
  Future<List<AvatarModel>> getAvatars();
  Future<Map<String, dynamic>> verifyReferralCode(String code);
  Future<bool> socialExists(Map<String, dynamic> params);
  Future<bool> forgotPassword(String email);
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
        if (data['code'] == 200) {
           final userMap = data['user'];
           userMap['token'] = data['token'];
           userMap['refreshToken'] = data['refreshToken'];
           return UserModel.fromJson(userMap);
        } else {
           throw ServerFailure(message: data['message'] ?? 'Login failed');
        }
      } else {
         throw ServerFailure(message: 'Login failed with status code ${response.statusCode}');
      }
    } on DioException catch (e) {
       throw ServerFailure(message: e.message ?? 'Unknown error');
    } catch (e) {
       throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<UserModel> socialLogin(String socialType, String socialId, String email, String name, String photoUrl) async {
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
        if (data['code'] == 200) {
           if (data['token'] != null) {
              final userMap = data['user'];
              userMap['token'] = data['token'];
              userMap['refreshToken'] = data['refreshToken'];
              return UserModel.fromJson(userMap);
           } else {
              throw const UserNotRegisteredFailure(message: 'User not registered');
           }
        } else {
           throw ServerFailure(message: data['message'] ?? 'Social Login failed');
        }
      } else {
         throw ServerFailure(message: 'Social Login failed with status code ${response.statusCode}');
      }
    } on DioException catch (e) {
       throw ServerFailure(message: e.message ?? 'Unknown error');
    } catch (e) {
       if (e is UserNotRegisteredFailure) rethrow;
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
        if (resData['code'] == 200) {
           final userMap = resData['user'] ?? resData['data']; // Check API structure
           if (resData['token'] != null) {
              userMap['token'] = resData['token'];
              userMap['refreshToken'] = resData['refreshToken'];
           }
           return UserModel.fromJson(userMap);
        } else {
           throw ServerFailure(message: resData['message'] ?? 'Registration failed');
        }
      } else {
         throw ServerFailure(message: 'Registration failed with status code ${response.statusCode}');
      }
    } on DioException catch (e) {
       throw ServerFailure(message: e.message ?? 'Unknown error');
    } catch (e) {
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
          if (resData['status'] == 200) {
             return true; 
          } else {
             throw ServerFailure(message: resData['message'] ?? 'Sending OTP failed');
          }
       } else {
          throw ServerFailure(message: 'Sending OTP failed: ${response.statusCode}');
       }
     } on DioException catch (e) {
        throw ServerFailure(message: e.message ?? 'Unknown error');
     } catch (e) {
        throw ServerFailure(message: e.toString());
     }
  }
  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await apiClient.get(myProfileUrl);

      if (response.statusCode == 200) {
        final resData = response.data;
         if (resData['code'] == 200) {
           return UserModel.fromJson(resData['userData'] ?? resData['data'] ?? {}); 
        } else {
           throw ServerFailure(message: resData['message'] ?? 'Failed to load profile');
        }
      } else {
        throw ServerFailure(message: 'Profile load failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerFailure(message: e.message ?? 'Unknown error');
    } catch (e) {
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
           if (resData['code'] == 200) {
              return true; 
           } else {
              throw ServerFailure(message: resData['message'] ?? 'OTP Verification failed');
           }
        } else {
           throw ServerFailure(message: 'OTP Verification failed: ${response.statusCode}');
        }
      } on DioException catch (e) {
         throw ServerFailure(message: e.message ?? 'Unknown error');
      } catch (e) {
         throw ServerFailure(message: e.toString());
      }
  }

  @override
  Future<bool> checkUserName(String userName) async {
    try {
      final response = await apiClient.post(checkUserNameUrl, data: {"username": userName});
      if (response.statusCode == 200) {
        final data = response.data;
        return data['code'] == 200;
      }
      return false;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        return false;
      }
      throw ServerFailure(message: 'Failed to check username');
    }
  }

  @override
  Future<bool> checkEmail(String email) async {
    try {
      final response = await apiClient.post(checkEmailUrl, data: {"email": email});
      final data = response.data;
      return data['code'] == 200;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        return false;
      }
       throw ServerFailure(message: 'Failed to check email');
    }
  }

  @override
  Future<bool> checkPhone(String phone) async {
    try {
      final response = await apiClient.get('$checkPhoneUrl$phone');
       final data = response.data;
      return data['code'] == 200;
    } catch (e) {
       if (e is DioException && e.response?.statusCode == 400) {
        return false;
      }
       throw ServerFailure(message: 'Failed to check phone');
    }
  }

  @override
  Future<List<AvatarModel>> getAvatars() async {
    try {
      final response = await apiClient.get(getAvatarsUrl);
      if (response.statusCode == 200) {
        final data = response.data;
        // API returns: {"base_url": "...", "response": [...]}
        final String baseUrl = data['base_url'] ?? '';
        final List list = data['response'] ?? [];
        return list.map((e) => AvatarModel.fromJson(e, baseUrl: baseUrl)).toList();
      }
      return [];
    } catch (e) {
       throw ServerFailure(message: 'Failed to get avatars');
    }
  }

  @override
  Future<Map<String, dynamic>> verifyReferralCode(String code) async {
    try {
      final response = await apiClient.post(referralUrl, data: {"referral_code": code});
       if (response.statusCode == 200) {
        return response.data;
       }
       throw ServerFailure(message: 'Referral code verification failed: ${response.statusCode}');
    } catch (e) {
       throw ServerFailure( message: 'Referral code verification failed');
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
        
        response = await apiClient.multipartPost(socialLoginRegisterUrl, formData: formData);
      } else {
        // Normal JSON request
        response = await apiClient.post(socialLoginRegisterUrl, data: data);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData['code'] == 200) {
           final userMap = resData['user'] ?? resData['data']; 
           if (resData['token'] != null) {
              userMap['token'] = resData['token'];
              userMap['refreshToken'] = resData['refreshToken'];
           }
           return UserModel.fromJson(userMap);
        } else {
           throw ServerFailure(message: resData['message'] ?? 'Social Registration failed');
        }
      } else {
         throw ServerFailure(message: 'Social Registration failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
       throw ServerFailure(message: e.message ?? 'Unknown error');
    } catch (e) {
       throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await apiClient.post(forgotPasswordUrl, data: {"email": email});
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200) {
          return true;
        } else {
          throw ServerFailure(message: data['message'] ?? 'Forgot password failed');
        }
      } else {
         throw ServerFailure(message: 'Forgot password failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
       throw ServerFailure(message: e.message ?? 'Unknown error');
    } catch (e) {
       throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<bool> verifyForgotPasswordOtp(String email, String otp) async {
    try {
      final response = await apiClient.post(verifyForgotPasswordOTPUrl, data: {"email": email, "otp": otp});
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
         throw ServerFailure(message: 'Verify OTP failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
       throw ServerFailure(message: e.message ?? 'Unknown error');
    } catch (e) {
       throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<bool> resetPassword(String email, String password) async {
    try {
      final response = await apiClient.post(resetPasswordUrl, data: {"email": email, "password": password});
      if (response.statusCode == 200) {
         final data = response.data;
         if (data['code'] == 200) {
           return true;
         } else {
           throw ServerFailure(message: data['message'] ?? 'Reset password failed');
         }
      } else {
          throw ServerFailure(message: 'Reset password failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
       throw ServerFailure(message: e.message ?? 'Unknown error');
    } catch (e) {
       throw ServerFailure(message: e.toString());
    }
  }
}
