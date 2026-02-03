import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/widgets/common_widgets.dart';

import '../models/admin_contact_info_model.dart';
import '../../../publish/data/models/category_data_model.dart';
import '../models/faq_model.dart';

abstract class AccountSettingsRemoteDataSource {
  Future<bool> deleteAccount(Map<String, String> reason);
  Future<AdminContactInfoModel> getAdminContactInfo();
  Future<List<FAQModel>> getFAQs(String category, int offset, int limit);
  Future<List<FAQModel>> getPriceTips(String category, int offset, int limit);
  Future<List<CategoryDataModel>> getFAQCategories(String type);
}

class AccountSettingsRemoteDataSourceImpl
    implements AccountSettingsRemoteDataSource {
  final ApiClient apiClient;

  AccountSettingsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<bool> deleteAccount(Map<String, String> reason) async {
    try {
      final response = await apiClient.post(
        ApiConstantsNew.profile.deleteAccount,
        data: reason,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        // Check for success flag or code in various locations to be robust
        if (data['success'] == true ||
            data['code'] == 200 ||
            (data['data'] != null &&
                data['data'] is Map &&
                data['data']['code'] == 200)) {
          return true;
        }
        throw ServerFailure(
            message: data['message'] ?? 'Failed to delete account');
      }
      throw const ServerFailure(message: 'Failed to delete account');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<AdminContactInfoModel> getAdminContactInfo() async {
    try {
      final response = await apiClient.get(ApiConstantsNew.misc.adminDetails);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is String) {}
        return AdminContactInfoModel.fromJson(data);
      }
      throw const ServerFailure(message: 'Failed to fetch admin details');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<FAQModel>> getFAQs(String category, int offset, int limit) async {
    try {
      final response = await apiClient.get(
        ApiConstantsNew.misc.generalMgmt,
        queryParameters: {
          'category': category.toLowerCase(),
          'offset': offset,
          'limit': limit,
          'type': 'FAQ',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map) {
          if (data['data'] != null && data['data'] is List) {
            return (data['data'] as List)
                .map((e) => FAQModel.fromJson(e))
                .toList();
          } else if (data['status'] != null && data['status'] is List) {
            return (data['status'] as List)
                .map((e) => FAQModel.fromJson(e))
                .toList();
          }
        }
        return [];
      }
      throw const ServerFailure(message: 'Failed to fetch FAQs');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<FAQModel>> getPriceTips(
      String category, int offset, int limit) async {
    try {
      final response = await apiClient.get(
        ApiConstantsNew.payments.priceTips,
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
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<CategoryDataModel>> getFAQCategories(String type) async {
    try {
      final response = await apiClient.get(
        ApiConstantsNew.content.hopperCategory,
        queryParameters: {'type': type},
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
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
