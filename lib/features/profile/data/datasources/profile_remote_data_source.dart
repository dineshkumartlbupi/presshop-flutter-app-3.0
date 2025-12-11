import 'package:dio/dio.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/core_export.dart';
import '../models/profile_data_model.dart';
import '../models/avatar_model.dart';

import 'package:presshop/core/api/api_client.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileDataModel> getProfile();
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
  Future<ProfileDataModel> getProfile() async {
    try {
      final response = await apiClient.get(myProfileUrl);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200) {
          return ProfileDataModel.fromJson(data['userData'] ?? data['data']);
        }
        throw ServerFailure(message: data['message'] ?? 'Failed to load profile');
      }
      throw ServerFailure(message: 'Failed to load profile');
    } catch (e) {
      throw ServerFailure(message: e.toString());
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

      Response response;
      if (imagePath != null && imagePath.isNotEmpty) {
        FormData formData = FormData.fromMap(data);
        formData.files.add(MapEntry(
          "profile_image",
          await MultipartFile.fromFile(imagePath),
        ));
        response = await apiClient.multipartPost(editProfileUrl, formData: formData);
      } else {
        response = await apiClient.post(editProfileUrl, data: data);
      }

      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData['code'] == 200) {
          return ProfileDataModel.fromJson(resData['userData'] ?? resData['data']);
        }
        throw ServerFailure(message: resData['message'] ?? 'Update failed');
      }
      throw ServerFailure(message: 'Update failed');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<String> uploadProfileImage(String imagePath) async {
    try {
      FormData formData = FormData.fromMap({
        "profile_image": await MultipartFile.fromFile(imagePath),
      });

      final response = await apiClient.multipartPost(editProfileUrl, formData: formData);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200) {
          final userData = data['userData'] ?? data['data'];
          return userData['profile_image'] ?? '';
        }
        throw ServerFailure(message: data['message'] ?? 'Upload failed');
      }
      throw ServerFailure(message: 'Upload failed');
    } catch (e) {
      throw ServerFailure(message: e.toString());
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
        throw ServerFailure(message: data['message'] ?? 'Password change failed');
      }
      throw ServerFailure(message: 'Password change failed');
    } catch (e) {
      throw ServerFailure(message: e.toString());
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
      // If error, assume false or throw? If checking availability, error usually means we can't check.
      // But adhering to failure pattern:
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<List<AvatarModel>> getAvatars() async {
    try {
      final response = await apiClient.get(getAvatarsUrl);
      if (response.statusCode == 200) {
        final data = response.data;
        final List list = data['response'] ?? [];
        return list.map((e) => AvatarModel.fromJson(e)).toList();
      }
      throw ServerFailure(message: 'Failed to load avatars');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
}
