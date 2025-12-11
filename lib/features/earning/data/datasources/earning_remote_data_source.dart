import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constant.dart';
import '../../../../core/error/exceptions.dart';
import '../../data/models/earning_model.dart';
import '../models/earning_model.dart';

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

    if (response.statusCode == 200) {
      var data = response.data;
      if (data is String) data = jsonDecode(data);
      return EarningProfileDataModel.fromJson(data['resp']);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<Map<String, dynamic>> getTransactions(Map<String, dynamic> params) async {
    final response = await apiClient.get(
      getAllEarningTransactionAPI,
      queryParameters: params,
    );

    if (response.statusCode == 200) {
      var data = response.data;
      if (data is String) data = jsonDecode(data);
      // Return raw data usually, or specific structure. 
      // Since we need 'totalEarning' which is outside 'data' list in some responses, let's return the whole json data map.
      return data is Map<String, dynamic> ? data : {};
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<CommissionData>> getCommissions(Map<String, dynamic> params) async {
    final response = await apiClient.get(
      commissionGetUrl,
      queryParameters: params,
    );

    if (response.statusCode == 200) {
      var data = response.data;
      if (data is String) data = jsonDecode(data);
      var dataList = data['data'] as List;
      return dataList.map((e) => CommissionData.fromJson(e)).toList();
    } else {
      throw ServerException();
    }
  }
}
