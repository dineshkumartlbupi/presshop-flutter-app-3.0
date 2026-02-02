import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/leaderboard/domain/entities/leaderboard_entity.dart';
import 'package:presshop/features/leaderboard/domain/usecases/get_leaderboard.dart';
import 'package:presshop/features/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import 'package:presshop/features/leaderboard/presentation/bloc/leaderboard_event.dart';
import 'package:presshop/features/leaderboard/presentation/bloc/leaderboard_state.dart';

class MockGetLeaderboardData extends Mock implements GetLeaderboardData {}

void main() {
  late LeaderboardBloc bloc;
  late MockGetLeaderboardData mockGetLeaderboardData;

  setUp(() {
    mockGetLeaderboardData = MockGetLeaderboardData();
    bloc = LeaderboardBloc(getLeaderboardData: mockGetLeaderboardData);
  });

  tearDown(() {
    bloc.close();
  });

  const tCountryCode = 'US';

  final tMember = MemberEntity(
      id: '1',
      userName: 'User1',
      country: 'US',
      createdAt: DateTime(2023),
      totalEarnings: '100',
      avatar: 'avatar.jpg');

  final tCountry = LeaderboardCountryEntity(country: 'USA', countryCode: 'US');

  final tLeaderboardEntity = LeaderboardEntity(
      totalMember: 1, countryList: [tCountry], memberList: [tMember]);

  group('LeaderboardBloc', () {
    test('initial state is LeaderboardInitial', () {
      expect(bloc.state, LeaderboardInitial());
    });

    blocTest<LeaderboardBloc, LeaderboardState>(
        'emits [Loading, Loaded] when GetLeaderboard succeeds',
        build: () {
          when(() => mockGetLeaderboardData(any()))
              .thenAnswer((_) async => Right(tLeaderboardEntity));
          return bloc;
        },
        act: (bloc) => bloc.add(const GetLeaderboard(tCountryCode)),
        expect: () => [
              LeaderboardLoading(),
              LeaderboardLoaded(tLeaderboardEntity),
            ],
        verify: (_) {
          verify(() => mockGetLeaderboardData(tCountryCode)).called(1);
        });

    blocTest<LeaderboardBloc, LeaderboardState>(
        'emits [Loading, Error] when GetLeaderboard fails',
        build: () {
          when(() => mockGetLeaderboardData(any())).thenAnswer(
              (_) async => const Left(ServerFailure(message: 'Server Error')));
          return bloc;
        },
        act: (bloc) => bloc.add(const GetLeaderboard(tCountryCode)),
        expect: () => [
              LeaderboardLoading(),
              LeaderboardError('Server Error'),
            ],
        verify: (_) {
          verify(() => mockGetLeaderboardData(tCountryCode)).called(1);
        });
  });
}
