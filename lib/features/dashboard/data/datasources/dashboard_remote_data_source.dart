import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/core_export.dart';
import '../models/admin_detail_model.dart';
import '../models/task_detail_model.dart';
import 'package:presshop/core/api/api_client.dart';

abstract class DashboardRemoteDataSource {
  Future<List<AdminDetailModel>> getActiveAdmins();
  Future<void> updateLocation(Map<String, dynamic> params);
  Future<void> addDevice(Map<String, dynamic> params);
  Future<TaskDetailModel> getTaskDetail(String id);
  Future<Map<String, dynamic>> getRoomId();
  Future<Map<String, dynamic>> checkAppVersion();
  Future<Map<String, dynamic>> activateStudentBeans();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<AdminDetailModel>> getActiveAdmins() async {
    try {
      final response = await apiClient.get(getAdminListUrl);
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
        throw ServerFailure();
      }
    } catch (e) {
      throw ServerFailure();
    }
  }

  @override
  Future<void> updateLocation(Map<String, dynamic> params) async {
     try {
      final response = await apiClient.post(updateLocation, data: params);
      if (response.statusCode != 200) {
        throw ServerFailure();
      }
    } catch (e) {
      throw ServerFailure();
    }
  }

  @override
  Future<void> addDevice(Map<String, dynamic> params) async {
     try {
      final response = await apiClient.post(addDeviceUrl, data: params);
      if (response.statusCode != 200) {
        throw ServerFailure();
      }
    } catch (e) {
      throw ServerFailure();
    }
  }

  @override
  Future<TaskDetailModel> getTaskDetail(String id) async {
    try {
      final response = await apiClient.get("$taskDetailUrl$id");
       if (response.statusCode == 200) {
         final data = response.data;
           if (data is String) {
            final decoded = jsonDecode(data);
             return TaskDetailModel.fromJson(decoded['task']);
        }
        return TaskDetailModel.fromJson(data['task']);
      } else {
        throw ServerFailure();
      }
    } catch (e) {
      throw ServerFailure();
    }
  }

  @override
  Future<Map<String, dynamic>> getRoomId() async {
     try {
      final response = await apiClient.get(getRoomIdUrl);
       if (response.statusCode == 200) {
         final data = response.data;
           if (data is String) {
            return jsonDecode(data);
        }
        return data;
      } else {
        throw ServerFailure();
      }
    } catch (e) {
      throw ServerFailure();
    }
  }

  @override
  Future<Map<String, dynamic>> checkAppVersion() async {
     try {
      final response = await apiClient.get(getLatestVersionUrl); 
       if (response.statusCode == 200) {
         final data = response.data;
           if (data is String) {
            return jsonDecode(data);
        }
        return data;
      } else {
        throw ServerFailure();
      }
    } catch (e) {
      throw ServerFailure();
    }
  }

  @override
  Future<Map<String, dynamic>> activateStudentBeans() async {
     try {
      final response = await apiClient.post(studentBeansActivationUrl); 
       if (response.statusCode == 200) {
         final data = response.data;
           if (data is String) {
            return jsonDecode(data);
        }
        return data;
      } else {
        throw ServerFailure();
      }
    } catch (e) {
      throw ServerFailure();
    }
  }
}
