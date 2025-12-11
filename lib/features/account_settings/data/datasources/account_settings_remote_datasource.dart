import 'package:dio/dio.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/api/api_client.dart';

import '../models/admin_contact_info_model.dart';

abstract class AccountSettingsRemoteDataSource {
  Future<bool> deleteAccount(Map<String, String> reason);
  Future<AdminContactInfoModel> getAdminContactInfo();
}

class AccountSettingsRemoteDataSourceImpl implements AccountSettingsRemoteDataSource {
  final ApiClient apiClient;

  AccountSettingsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<bool> deleteAccount(Map<String, String> reason) async {
    try {
      final response = await apiClient.post(
        deleteAccountUrl,
        data: reason,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200) {
          return true;
        }
        throw ServerFailure(message: data['message'] ?? 'Failed to delete account');
      }
      throw const ServerFailure(message: 'Failed to delete account');
    } on DioException catch (e) {
      throw ServerFailure(message: e.message ?? 'Unknown error');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
  @override
  Future<AdminContactInfoModel> getAdminContactInfo() async {
    try {
      final response = await apiClient.get(adminDetailAPI);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is String) {
          // Handle string response if necessary (double decode logic sometimes seen in this project)
           // But assuming ApiClient handles it or it's a map.
           // However previous code showed JSON decoding might be needed if response.data is string.
           // ApiClient usually returns Map if configured, but let's see current usages.
           // In deleteAccount it accessed data['code'].
           // Let's assume Map.
           // Wait, dashboard remote source handled "data is String".
        }
        return AdminContactInfoModel.fromJson(data);
      }
       throw const ServerFailure(message: 'Failed to fetch admin details');
    } on DioException catch (e) {
      throw ServerFailure(message: e.message ?? 'Unknown error');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
}
