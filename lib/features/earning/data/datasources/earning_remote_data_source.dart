
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/constants/api_constant.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';

abstract class EarningRemoteDataSource {
  Future<EarningProfileDataModel> getEarningProfile(String year, String month);
  Future<Map<String, dynamic>> getTransactions(Map<String, dynamic> params);
  Future<List<CommissionData>> getCommissions(Map<String, dynamic> params);
}

class EarningRemoteDataSourceImpl implements EarningRemoteDataSource {
  final ApiClient apiClient;

  EarningRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<EarningProfileDataModel> getEarningProfile(String year, String month) async {
    final response = await apiClient.get(
      getEarningDataAPI,
      queryParameters: {"year": year, "month": month},
    );

    // ApiClient usually returns dynamic (Map or List) directly if configured, 
    // or we might need to handle it. Assuming it behaves like in PublicationRemoteDataSourceImpl.
    final data = response.data;
    return EarningProfileDataModel.fromJson(data);
  }

  @override
  Future<Map<String, dynamic>> getTransactions(Map<String, dynamic> params) async {
    final response = await apiClient.get(
      getAllEarningTransactionAPI,
      queryParameters: params,
    );
    // Returning full response to extract totalEarning and data list in Repository
    return response as Map<String, dynamic>;
  }

  @override
  Future<List<CommissionData>> getCommissions(Map<String, dynamic> params) async {
    final response = await apiClient.get(
      commissionGetUrl,
      queryParameters: params,
    );
    
    final List<dynamic> dataList = response.data;
    return dataList.map((e) => CommissionData.fromJson(e)).toList();
  }
}
