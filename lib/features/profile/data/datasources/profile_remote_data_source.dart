import 'package:dio/dio.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:presshop/core/error/failures.dart';
import '../models/profile_data_model.dart';
import '../models/avatar_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileDataModel> getProfile(String userId);
  Future<ProfileDataModel> updateProfile(Map<String, dynamic> data);
  Future<String> uploadProfileImage(String imagePath);
  Future<void> changePassword(String oldPassword, String newPassword);
  Future<bool> checkUserName(String username);
  Future<List<AvatarModel>> getAvatars();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ProfileDataModel> getProfile(String userId) async {
    print("🔍 DEBUG: getProfile called with userId: '$userId'");
    try {
      final response = await apiClient.get(
        myProfileUrl,
        queryParameters: {"userId": userId},
      );
      print("🔍 DEBUG: API Response Status: ${response.statusCode}");
      print("🔍 DEBUG: API Response Data: ${response.data}");
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200 || data['success'] == true) {
          return ProfileDataModel.fromJson(data['userData'] ?? data['data']);
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
  Future<ProfileDataModel> updateProfile(Map<String, dynamic> data) async {
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
        response = await apiClient.multipartPost(editProfileUrl,
            formData: formData, options: options);
      } else {
        response =
            await apiClient.post(editProfileUrl, data: data, options: options);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData['code'] == 200 || resData['success'] == true) {
          return ProfileDataModel.fromJson(
              resData['userData'] ?? resData['data']);
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

      final response = await apiClient.multipartPost(editProfileUrl,
          formData: formData, options: options);
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
        changePasswordUrl,
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
      final response = await apiClient.get("$checkUserNameUrl$username");
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
      final response = await apiClient.get(getAvatarsUrl);
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
