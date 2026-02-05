import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_leaderboard.dart';
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
    emit(LeaderboardLoading());
    final result = await getLeaderboardData(event.countryCode);
    result.fold(
      (failure) {
        debugPrint(
            "DEBUG: LeaderboardBloc GetLeaderboard failure: ${failure.message}");
        emit(LeaderboardError(failure.message));
      },
      (data) {
        debugPrint(
            "DEBUG: LeaderboardBloc GetLeaderboard success, members: ${data.memberList.length}");
        emit(LeaderboardLoaded(data));
      },
    );
  }
}
