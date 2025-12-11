import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/features/bank/data/models/bank_detail_model.dart';
import 'package:presshop/core/error/failures.dart';

abstract class BankRemoteDataSource {
  Future<List<BankDetailModel>> getBanks();
  Future<void> deleteBank(String id, String stripeBankId);
  Future<void> setDefaultBank(String stripeBankId, bool isDefault);
  Future<String> getStripeOnboardingUrl();
}

class BankRemoteDataSourceImpl implements BankRemoteDataSource {
  final ApiClient apiClient;

  BankRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<BankDetailModel>> getBanks() async {
    try {
      final response = await apiClient.get(bankListUrl);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200) {
          final List list = data["bankList"] ?? [];
          return list.map((e) => BankDetailModel.fromJson(e)).toList();
        }
        throw ServerFailure(message: data['message'] ?? 'Failed to load banks');
      }
      throw ServerFailure(message: 'Failed to load banks');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<void> deleteBank(String id, String stripeBankId) async {
    try {
      final response = await apiClient.delete("$deleteBankUrl$id/$stripeBankId");
      if (response.statusCode == 200) {
        return;
      }
      throw ServerFailure(message: 'Failed to delete bank');
    } catch (e) {
      throw ServerFailure(message: e.toString());
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
      final response = await apiClient.patch(editBankUrl, data: map);
      if (response.statusCode == 200) {
        return;
      }
      throw ServerFailure(message: 'Failed to update bank');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<String> getStripeOnboardingUrl() async {
    try {
      // Endpoint found: "hopper/add-express-bank-account" assigned to generateStripeBankApi constant
      final response = await apiClient.get(generateStripeBankApi);
      if (response.statusCode == 200) {
        final data = response.data;
        // Legacy code: Navigator.push(CommonWebView(webUrl: data['accountLink']))
        if (data['accountLink'] != null) {
          return data['accountLink'];
        } else if (data['error'] != null) {
          throw ServerFailure(message: data['error']);
        }
        throw ServerFailure(message: 'No account link found');
      }
      throw ServerFailure(message: 'Failed to generate stripe link');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
}
