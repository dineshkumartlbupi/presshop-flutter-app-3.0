import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../domain/usecases/get_leaderboard.dart';
import '../../data/models/leaderboard_model.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc({required this.getLeaderboardData})
      : super(LeaderboardInitial()) {
    on<GetLeaderboard>(_onGetLeaderboard);
  }
  final GetLeaderboardData getLeaderboardData;

  Future<void> _onGetLeaderboard(
      GetLeaderboard event, Emitter<LeaderboardState> emit) async {
    final cacheBox = Hive.box('sync_cache');
    final String cacheKey = 'leaderboard_${event.countryCode}';

    final cachedData = cacheBox.get(cacheKey);
    if (cachedData != null) {
      try {
        final data = LeaderboardModel.fromJson(cachedData);
        emit(LeaderboardLoaded(data));
      } catch (e) {
        debugPrint("Error loading leaderboard from cache: $e");
      }
    }

    if (state is! LeaderboardLoaded) {
      emit(LeaderboardLoading());
    }

    final result = await getLeaderboardData(event.countryCode);
    result.fold(
      (failure) {
        debugPrint(
            "DEBUG: LeaderboardBloc GetLeaderboard failure: ${failure.message}");
        if (state is! LeaderboardLoaded) {
          emit(LeaderboardError(failure.message));
        }
      },
      (data) {
        debugPrint(
            "DEBUG: LeaderboardBloc GetLeaderboard success, members: ${data.memberList.length}");
        cacheBox.put(cacheKey, (data as LeaderboardModel).toJson());
        emit(LeaderboardLoaded(data));
      },
    );
  }
}
