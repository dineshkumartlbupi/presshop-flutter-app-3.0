import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';
import 'package:presshop/core/error/api_error_handler.dart';

abstract class EarningRemoteDataSource {
  Future<EarningProfileDataModel> getEarningProfile(String year, String month);
  Future<Map<String, dynamic>> getTransactions(Map<String, dynamic> params);
  Future<List<CommissionData>> getCommissions(Map<String, dynamic> params);
}

class EarningRemoteDataSourceImpl implements EarningRemoteDataSource {
  EarningRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<EarningProfileDataModel> getEarningProfile(
      String year, String month) async {
    try {
      final response = await apiClient.get(
        ApiConstantsNew.payments.earnings,
        queryParameters: {"year": year, "month": month},
      );
      final data = response.data;
      return EarningProfileDataModel.fromJson(data);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getTransactions(
      Map<String, dynamic> params) async {
    try {
      final response = await apiClient.get(
        ApiConstantsNew.payments.earningTransactions,
        queryParameters: params,
      );
      return response.data;
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<CommissionData>> getCommissions(
      Map<String, dynamic> params) async {
    try {
      final response = await apiClient.get(
        ApiConstantsNew.payments.commission,
        queryParameters: params,
      );

      final dynamic responseData = response.data;
      final List<dynamic> dataList;

      if (responseData is Map) {
        dataList = (responseData['data'] as List?) ?? [];
      } else if (responseData is List) {
        dataList = responseData;
      } else {
        dataList = [];
      }

      return dataList.map((e) => CommissionData.fromJson(e)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
