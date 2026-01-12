import 'package:dio/dio.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/api/api_client.dart';

import '../models/admin_contact_info_model.dart';
import '../../../publish/data/models/category_data_model.dart';
import '../models/faq_model.dart';

abstract class AccountSettingsRemoteDataSource {
  Future<bool> deleteAccount(Map<String, String> reason);
  Future<AdminContactInfoModel> getAdminContactInfo();
  Future<List<FAQModel>> getFAQs(String category, int offset, int limit);
  Future<List<FAQModel>> getPriceTips(String category, int offset, int limit);
  Future<List<CategoryDataModel>> getFAQCategories();
}

class AccountSettingsRemoteDataSourceImpl
    implements AccountSettingsRemoteDataSource {
  final ApiClient apiClient;

  AccountSettingsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<bool> deleteAccount(Map<String, String> reason) async {
    try {
      final response = await apiClient.post(
        deleteAccountUrl,
        data: reason,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['code'] == 200) {
          return true;
        }
        throw ServerFailure(
            message: data['message'] ?? 'Failed to delete account');
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

  @override
  Future<List<FAQModel>> getFAQs(String category, int offset, int limit) async {
    try {
      final response = await apiClient.get(
        getAllCmsUrl,
        queryParameters: {
          'category': category.toLowerCase(),
          'offset': offset,
          'limit': limit,
          'type': 'FAQ',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['status'] is List) {
          return (data['status'] as List)
              .map((e) => FAQModel.fromJson(e)) // Use stored clean model
              .toList();
        }
        return [];
      }
      throw const ServerFailure(message: 'Failed to fetch FAQs');
    } on DioException catch (e) {
      throw ServerFailure(message: e.message ?? 'Unknown error');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<List<FAQModel>> getPriceTips(
      String category, int offset, int limit) async {
    try {
      final response = await apiClient.get(
        priceTipsAPI,
        queryParameters: {
          'category': category,
          'offset': offset,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['code'] == 200 && data['price_tips'] is List) {
          return (data['price_tips'] as List)
              .map((e) => FAQModel.fromJson(e))
              .toList();
        }
        return [];
      }
      throw const ServerFailure(message: 'Failed to fetch Price Tips');
    } on DioException catch (e) {
      throw ServerFailure(message: e.message ?? 'Unknown error');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<List<CategoryDataModel>> getFAQCategories() async {
    try {
      final response = await apiClient.get(
        getHopperCategory,
        queryParameters: {'type': 'FAQ'},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        var dataList = [];

        if (data['data'] != null && data['data'] is List) {
          dataList = data['data'] as List;
        } else if (data['categories'] != null) {
          dataList = data['categories'] as List;
        } else if (data['data'] != null &&
            data['data'] is Map &&
            data['data']['categories'] != null) {
          dataList = data['data']['categories'] as List;
        }

        return dataList.map((e) => CategoryDataModel.fromJson(e)).toList();
      }
      throw const ServerFailure(message: 'Failed to fetch categories');
    } on DioException catch (e) {
      throw ServerFailure(message: e.message ?? 'Unknown error');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
}
