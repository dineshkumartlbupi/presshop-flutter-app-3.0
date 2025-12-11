import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constant.dart';
import '../models/leaderboard_model.dart';

abstract class LeaderboardRemoteDataSource {
  Future<LeaderboardModel> getLeaderboardData(String countryCode);
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final ApiClient apiClient;

  LeaderboardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<LeaderboardModel> getLeaderboardData(String countryCode) async {
    final response = await apiClient.get(
      leadershipurl,
      queryParameters: {'country': countryCode},
    );
    
    return LeaderboardModel.fromJson(response.data);
  }
}
