import 'package:flutter/foundation.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/features/bank/data/models/bank_detail_model.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:presshop/core/error/failures.dart';

abstract class BankRemoteDataSource {
  Future<List<BankDetailModel>> getBanks();
  Future<void> deleteBank(String id, String stripeBankId);
  Future<void> setDefaultBank(String stripeBankId, bool isDefault);
  Future<String> getStripeOnboardingUrl();
}

class BankRemoteDataSourceImpl implements BankRemoteDataSource {
  BankRemoteDataSourceImpl(this.apiClient);
  final ApiClient apiClient;

  @override
  Future<List<BankDetailModel>> getBanks() async {
    try {
      final response = await apiClient.get(ApiConstantsNew.profile.bankList);
      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint("BankRemoteDataSource: Data keys: ${data.keys}");
        debugPrint(
            "BankRemoteDataSource: success: ${data['success']} (${data['success'].runtimeType})");

        bool isSuccess = data['success'] == true ||
            data['success']?.toString() == "true" ||
            data['code'] == 200 ||
            data['code']?.toString() == "200";

        if (isSuccess) {
          final bankData = data['data'] ?? data;
          final List list = bankData["bankList"] ?? [];
          debugPrint("BankRemoteDataSource: Found ${list.length} banks");
          return list
              .map(
                  (e) => BankDetailModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }

        debugPrint(
            "BankRemoteDataSource: Success check failed, throwing message: ${data['message']}");
        throw ServerFailure(
            message:
                (data['message'] ?? data['error'] ?? 'Failed to load banks')
                    .toString());
      }
      throw ServerFailure(message: 'Failed to load banks');
    } catch (e) {
      debugPrint("BankRemoteDataSource: Error during fetch: $e");
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteBank(String id, String stripeBankId) async {
    try {
      final response = await apiClient
          .delete("${ApiConstantsNew.profile.deleteBank}$id/$stripeBankId");
      if (response.statusCode == 200) {
        return;
      }
      throw ServerFailure(message: 'Failed to delete bank');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<void> setDefaultBank(String stripeBankId, bool isDefault) async {
    try {
      final map = {
        "is_default": isDefault.toString(),
        "stripe_bank_id": stripeBankId,
      };
      // NetworkClass used patch for editBankUrl
      final response =
          await apiClient.patch(ApiConstantsNew.profile.updateBank, data: map);
      if (response.statusCode == 200) {
        return;
      }
      throw ServerFailure(message: 'Failed to update bank');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<String> getStripeOnboardingUrl() async {
    try {
      // Endpoint found: "hopper/add-express-bank-account" assigned to generateStripeBankApi constant
      final response =
          await apiClient.get(ApiConstantsNew.payments.addExpressBank);
      if (response.statusCode == 200) {
        final data = response.data;
        // Legacy code: Navigator.push(CommonWebView(webUrl: data['accountLink']))
        if (data['accountLink'] != null) {
          return data['accountLink'];
        } else if (data['data'] != null &&
            data['data']['accountLink'] != null) {
          return data['data']['accountLink'];
        } else if (data['error'] != null) {
          throw ServerFailure(message: data['error']);
        }
        throw ServerFailure(message: 'No account link found');
      }
      throw ServerFailure(message: 'Failed to generate stripe link');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
