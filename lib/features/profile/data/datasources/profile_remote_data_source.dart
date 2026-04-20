import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:presshop/core/error/failures.dart';
import '../models/avatar_model.dart';
import '../../domain/entities/avatar.dart';
import '../models/user_profile_response.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile(String userId, {bool showLoader = true});
  Future<UserProfileModel> updateProfile(Map<String, dynamic> data);
  Future<String> uploadProfileImage(String imagePath);
  Future<void> changePassword(String oldPassword, String newPassword);
  Future<bool> checkUserName(String username);
  Future<List<Avatar>> getAvatars();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this.apiClient);
  final ApiClient apiClient;

  @override
  Future<UserProfileModel> getProfile(String userId,
      {bool showLoader = true}) async {
    try {
      final response = await apiClient.get(
        ApiConstantsNew.profile.myProfile,
        queryParameters: {"userId": userId},
        showLoader: showLoader,
      );
      if (response.statusCode == 200) {
        var map = response.data;
        if (map is String) map = jsonDecode(map);
        if (map["code"] == 200 || map["success"] == true) {
          var userData = map["userData"] ?? map["data"];
          if (userData is Map &&
              userData.containsKey('data') &&
              userData['data'] is Map) {
            userData = userData['data'];
          }
          if (userData is Map) {
            return UserProfileModel.fromJson(Map<String, dynamic>.from(userData));
          }
        }
        throw ServerFailure(
            message: map['message'] ?? 'Failed to load profile');
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

      String userId = apiClient.sharedPreferences
              .getString(SharedPreferencesKeys.hopperIdKey) ??
          "";
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
        var resData = response.data;
        if (resData is String) resData = jsonDecode(resData);
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

      String userId = apiClient.sharedPreferences
              .getString(SharedPreferencesKeys.hopperIdKey) ??
          "";
      Options options = Options(headers: {"x-user-id": userId});

      final response = await apiClient.multipartPost(
          ApiConstantsNew.profile.editProfile,
          formData: formData,
          options: options);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = response.data;
        if (data is String) data = jsonDecode(data);
        if (data['code'] == 200 || data['success'] == true) {
          final userData = data['userData'] ?? data['data'];
          if (userData != null && userData is Map) {
            return userData['profile_image']?.toString() ??
                data['profile_image']?.toString() ??
                '';
          }
          return data['profile_image']?.toString() ?? '';
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = response.data;
        if (data is String) data = jsonDecode(data);
        if (data['code'] == 200 || data['success'] == true) {
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
      final response = await apiClient.get(
        "${ApiConstantsNew.auth.checkUserName}$username",
        showLoader: false,
      );
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is String) data = jsonDecode(data);
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
      final response = await apiClient.get(ApiConstantsNew.profile.getAvatars,
          showLoader: false);
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is String) data = jsonDecode(data);
        final List list = data['data'] ?? [];
        return list.map((e) => AvatarModel.fromJson(e)).toList();
      }
      throw ServerFailure(message: 'Failed to load avatars');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
