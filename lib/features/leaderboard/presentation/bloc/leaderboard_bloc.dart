import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_leaderboard.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final GetLeaderboardData getLeaderboardData;

  LeaderboardBloc({required this.getLeaderboardData}) : super(LeaderboardInitial()) {
    on<GetLeaderboard>(_onGetLeaderboard);
  }

  Future<void> _onGetLeaderboard(GetLeaderboard event, Emitter<LeaderboardState> emit) async {
    emit(LeaderboardLoading());
    final result = await getLeaderboardData(event.countryCode);
    result.fold(
      (failure) => emit(LeaderboardError(failure.message)),
      (data) => emit(LeaderboardLoaded(data)),
    );
  }
}
