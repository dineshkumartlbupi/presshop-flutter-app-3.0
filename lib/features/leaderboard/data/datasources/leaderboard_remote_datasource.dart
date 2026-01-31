import 'package:flutter/foundation.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constant_new.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import '../models/leaderboard_model.dart';

abstract class LeaderboardRemoteDataSource {
  Future<LeaderboardModel> getLeaderboardData(String countryCode);
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final ApiClient apiClient;

  LeaderboardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<LeaderboardModel> getLeaderboardData(String countryCode) async {
    try {
      debugPrint("DEBUG: getLeaderboardData countryCode: $countryCode");
      final response = await apiClient.get(
        ApiConstantsNew.misc.leaderboard,
        queryParameters: {'country': countryCode},
      );
      debugPrint(
          "DEBUG: getLeaderboardData response keys: ${response.data is Map ? (response.data as Map).keys.toList() : 'Not a Map'}");
      debugPrint("DEBUG: getLeaderboardData response data: ${response.data}");

      return LeaderboardModel.fromJson(response.data);
    } catch (e) {
      debugPrint("DEBUG: getLeaderboardData ERROR: $e");
      throw ApiErrorHandler.handle(e);
    }
  }
}
