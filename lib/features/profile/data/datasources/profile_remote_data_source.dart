import 'package:dio/dio.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:presshop/core/error/failures.dart';
import '../models/avatar_model.dart';
import '../../domain/entities/avatar.dart';
import '../models/user_profile_response.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile(String userId);
  Future<UserProfileModel> updateProfile(Map<String, dynamic> data);
  Future<String> uploadProfileImage(String imagePath);
  Future<void> changePassword(String oldPassword, String newPassword);
  Future<bool> checkUserName(String username);
  Future<List<Avatar>> getAvatars();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserProfileModel> getProfile(String userId) async {
    print("🔍 DEBUG: getProfile called with userId: '$userId'");
    try {
      final response = await apiClient.get(
        ApiConstantsNew.profile.myProfile,
        queryParameters: {"userId": userId},
      );
      print("🔍 DEBUG: API Response Status: ${response.statusCode}");
      print("🔍 DEBUG: API Response Data: ${response.data}");
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200 || data['success'] == true) {
          return UserProfileResponse.fromJson(data).data;
        }
        throw ServerFailure(
            message: data['message'] ?? 'Failed to load profile');
      }
      throw ServerFailure(message: 'Failed to load profile');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<UserProfileModel> updateProfile(Map<String, dynamic> data) async {
    try {
      String? imagePath;
      if (data.containsKey('_imagePath')) {
        imagePath = data['_imagePath'];
        data.remove('_imagePath');
      }

      String userId = apiClient.sharedPreferences.getString(hopperIdKey) ?? "";
      Options options = Options(headers: {"x-user-id": userId});
      Response response;

      if (imagePath != null && imagePath.isNotEmpty) {
        FormData formData = FormData.fromMap(data);
        formData.files.add(MapEntry(
          "profile_image",
          await MultipartFile.fromFile(imagePath),
        ));
        response = await apiClient.multipartPost(
            ApiConstantsNew.profile.editProfile,
            formData: formData,
            options: options);
      } else {
        response = await apiClient.post(ApiConstantsNew.profile.editProfile,
            data: data, options: options);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData['code'] == 200 || resData['success'] == true) {
          return UserProfileResponse.fromJson(resData).data;
        }
        throw ServerFailure(message: resData['message'] ?? 'Update failed');
      }
      throw ServerFailure(
          message: 'Update failed with status ${response.statusCode}');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<String> uploadProfileImage(String imagePath) async {
    try {
      FormData formData = FormData.fromMap({
        "profile_image": await MultipartFile.fromFile(imagePath),
      });

      String userId = apiClient.sharedPreferences.getString(hopperIdKey) ?? "";
      Options options = Options(headers: {"x-user-id": userId});

      final response = await apiClient.multipartPost(
          ApiConstantsNew.profile.editProfile,
          formData: formData,
          options: options);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['code'] == 200 || data['success'] == true) {
          final userData = data['userData'] ?? data['data'];
          if (userData != null && userData is Map) {
            return userData['profile_image']?.toString() ?? '';
          }
          return '';
        }
        throw ServerFailure(message: data['message'] ?? 'Upload failed');
      }
      throw ServerFailure(
          message: 'Upload failed with status ${response.statusCode}');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await apiClient.post(
        ApiConstantsNew.profile.changePassword,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200) {
          return;
        }
        throw ServerFailure(
            message: data['message'] ?? 'Password change failed');
      }
      throw ServerFailure(message: 'Password change failed');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<bool> checkUserName(String username) async {
    try {
      final response =
          await apiClient.get("${ApiConstantsNew.auth.checkUserName}$username");
      if (response.statusCode == 200) {
        final data = response.data;
        return data['userNameExist'] ?? false;
      }
      return false;
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
        final List list = data['data'] ?? [];
        return list.map((e) => AvatarModel.fromJson(e)).toList();
      }
      throw ServerFailure(message: 'Failed to load avatars');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
