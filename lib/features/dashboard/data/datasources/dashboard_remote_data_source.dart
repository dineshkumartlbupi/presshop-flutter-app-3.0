import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/core_export.dart' hide AdminDetailModel;
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import '../models/admin_detail_model.dart';
import 'package:presshop/features/task/data/models/task_assigned_response_model.dart';

abstract class DashboardRemoteDataSource {
  Future<List<AdminDetailModel>> getActiveAdmins();
  Future<void> updateLocation(Map<String, dynamic> params);
  Future<void> addDevice(Map<String, dynamic> params);
  Future<TaskAssignedResponseModel> getTaskDetail(String id);
  Future<Map<String, dynamic>> getRoomId(Map<String, dynamic> params);
  Future<Map<String, dynamic>> checkAppVersion();
  Future<Map<String, dynamic>> activateStudentBeans();
  Future<void> markStudentBeansVisited();
  Future<Map<String, dynamic>> checkStudentBeans();
  Future<void> removeDevice(Map<String, dynamic> params);
}
// ================================= Implementation ================================
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  DashboardRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<List<AdminDetailModel>> getActiveAdmins() async {
    try {
      final response = await apiClient.get(ApiConstantsNew.misc.adminList,
          showLoader: false);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is String) {
          final decoded = jsonDecode(data);
          return (decoded['data'] as List)
              .map((e) => AdminDetailModel.fromJson(e))
              .toList();
        }
        return (data['data'] as List)
            .map((e) => AdminDetailModel.fromJson(e))
            .toList();

      } else {
        throw ServerFailure(message: '');
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<void> updateLocation(Map<String, dynamic> params) async {
    try {
      final response = await apiClient.post(
          ApiConstantsNew.profile.updateLocation,
          data: params,
          showLoader: false);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerFailure(message: '');
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<void> addDevice(Map<String, dynamic> params) async {
    debugPrint("🚀 Add Device API Request Body: $params");
    try {
      final response = await apiClient.post(ApiConstantsNew.profile.addDevice,
          data: params, showLoader: false);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerFailure(message: '');
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<TaskAssignedResponseModel> getTaskDetail(String id) async {
    try {
      final response = await apiClient.get(
          "${ApiConstantsNew.tasks.assignedTaskDetail}$id",
          showLoader: false);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is String) {
          final decoded = jsonDecode(data);
          return TaskAssignedResponseModel.fromJson(decoded);
        }
        return TaskAssignedResponseModel.fromJson(data);
      } else {
        throw ServerFailure(message: '');
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getRoomId(Map<String, dynamic> params) async {
    try {
      debugPrint(
          "🚀 Calling Create Room API: ${ApiConstantsNew.chat.createRoom}");
      debugPrint("📤 Create Room API Request Body: $params");
      final response = await apiClient.post(ApiConstantsNew.chat.createRoom,
          data: params, showLoader: false);
      debugPrint("📦 Create Room API Response Status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        Map<String, dynamic> responseMap;
        if (data is String) {
          responseMap = jsonDecode(data);
        } else {
          responseMap = Map<String, dynamic>.from(data);
        }

        // Ensure we return the map so the caller can extract _id
        return responseMap;
      } else {
        throw ServerFailure(
            message: 'Failed to create room: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Create Room API Error: $e");
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<Map<String, dynamic>> checkAppVersion() async {
    try {
      final response = await apiClient
          .get(ApiConstantsNew.auth.getLatestVersion, showLoader: false);
      if (response.statusCode == 200) {
        final data = response.data;
        final Map<String, dynamic> responseMap =
            data is String ? jsonDecode(data) : Map<String, dynamic>.from(data);

        if (responseMap['success'] == true && responseMap['data'] != null) {
          return responseMap['data'];
        }
        return responseMap;
      } else {
        throw ServerFailure(
            message: 'Failed to check app version: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<Map<String, dynamic>> activateStudentBeans() async {
    try {
      final response = await apiClient.post(
          ApiConstantsNew.profile.studentBeansActivation,
          showLoader: false);
      debugPrint(
          "🚀 Activate Student Beans API Response Status: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final responseMap =
            data is String ? jsonDecode(data) : Map<String, dynamic>.from(data);

        if (responseMap['success'] == true && responseMap['data'] != null) {
          return responseMap['data'];
        }
        return responseMap;
      } else {
        throw ServerFailure(message: '');
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<Map<String, dynamic>> checkStudentBeans() async {
    try {
      final userId = apiClient.sharedPreferences
          .getString(SharedPreferencesKeys.hopperIdKey);
      final response = await apiClient.get(
        ApiConstantsNew.profile.myProfile,
        queryParameters: userId != null ? {"userId": userId} : null,
        showLoader: false,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final responseMap =
            data is String ? jsonDecode(data) : Map<String, dynamic>.from(data);

        if (responseMap['success'] == true && responseMap['data'] != null) {
          return responseMap['data'];
        }
        return responseMap;
      } else {
        throw ServerFailure(message: '');
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<void> markStudentBeansVisited() async {
    try {
      await apiClient.sharedPreferences
          .setBool(SharedPreferencesKeys.sourceDataIsClickKey, true);
      await apiClient.sharedPreferences
          .setBool(SharedPreferencesKeys.sourceDataIsOpenedKey, true);
    } catch (e) {
      // Should we handle?
    }
  }

  @override
  Future<void> removeDevice(Map<String, dynamic> params) async {
    try {
      final response = await apiClient
          .post(ApiConstantsNew.profile.removeDevice, data: params);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerFailure(message: '');
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
