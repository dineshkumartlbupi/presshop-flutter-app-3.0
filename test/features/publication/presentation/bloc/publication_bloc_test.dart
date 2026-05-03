import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/publication/domain/entities/media_house.dart';
import 'package:presshop/features/publication/domain/entities/publication_earning_stats.dart';
import 'package:presshop/features/publication/domain/entities/publication_transactions_result.dart';
import 'package:presshop/features/publication/domain/usecases/get_media_houses.dart';
import 'package:presshop/features/publication/domain/usecases/get_publication_earning_stats.dart';
import 'package:presshop/features/publication/domain/usecases/get_publication_transactions.dart';
import 'package:presshop/features/publication/presentation/bloc/publication_bloc.dart';
import 'package:presshop/features/publication/presentation/bloc/publication_event.dart';
import 'package:presshop/features/publication/presentation/bloc/publication_state.dart';

class MockGetPublicationEarningStats extends Mock
    implements GetPublicationEarningStats {}

class MockGetMediaHouses extends Mock implements GetMediaHouses {}

class MockGetPublicationTransactions extends Mock
    implements GetPublicationTransactions {}

void main() {
  late PublicationBloc bloc;
  late MockGetPublicationEarningStats mockGetPublicationEarningStats;
  late MockGetMediaHouses mockGetMediaHouses;
  late MockGetPublicationTransactions mockGetPublicationTransactions;

  setUp(() {
    mockGetPublicationEarningStats = MockGetPublicationEarningStats();
    mockGetMediaHouses = MockGetMediaHouses();
    mockGetPublicationTransactions = MockGetPublicationTransactions();
    bloc = PublicationBloc(
      getPublicationEarningStats: mockGetPublicationEarningStats,
      getMediaHouses: mockGetMediaHouses,
      getPublicationTransactions: mockGetPublicationTransactions,
    );
    registerFallbackValue(NoParams());
  });

  tearDown(() {
    bloc.close();
  });

  const tContentId = '123';
  const tContentType = 'exclusive';

  const tStats = PublicationEarningStats(
    avatar: 'avatar.png',
    publicationCount: '10',
    totalEarning: '1000',
  );

  const tMediaHouses = [
    MediaHouse(id: '1', name: 'BBC', icon: 'bbc.png'),
    MediaHouse(id: '2', name: 'CNN', icon: 'cnn.png'),
  ];

  const tTransactionsResult = PublicationTransactionsResult(
    transactions: [],
    publicationCount: '10',
    totalAmount: '1000',
  );

  group('PublicationBloc', () {
    test('initial state is PublicationInitial', () {
      expect(bloc.state, PublicationInitial());
    });

    group('LoadPublicationInitialData', () {
      blocTest<PublicationBloc, PublicationState>(
        'emits [PublicationLoading, PublicationLoaded] when all data loads successfully',
        build: () {
          when(() => mockGetPublicationEarningStats(any()))
              .thenAnswer((_) async => const Right(tStats));
          when(() => mockGetMediaHouses(any()))
              .thenAnswer((_) async => const Right(tMediaHouses));
          when(() => mockGetPublicationTransactions(any()))
              .thenAnswer((_) async => const Right(tTransactionsResult));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadPublicationInitialData(
            contentId: tContentId, contentType: tContentType)),
        expect: () => [
          PublicationLoading(),
          const PublicationLoaded(
            stats: tStats,
            mediaHouses: tMediaHouses,
            transactionsResult: tTransactionsResult,
          ),
        ],
      );

      blocTest<PublicationBloc, PublicationState>(
        'emits [PublicationLoading, PublicationError] when any call fails',
        build: () {
          when(() => mockGetPublicationEarningStats(any())).thenAnswer(
              (_) async => const Left(ServerFailure(message: 'Stats Failed')));
          when(() => mockGetMediaHouses(any()))
              .thenAnswer((_) async => const Right(tMediaHouses));
          when(() => mockGetPublicationTransactions(any()))
              .thenAnswer((_) async => const Right(tTransactionsResult));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadPublicationInitialData(
            contentId: tContentId, contentType: tContentType)),
        expect: () => [
          PublicationLoading(),
          const PublicationError(message: "Failed to load data"),
        ],
      );
    });

    group('FilterPublicationTransactions', () {
      // Mock initial state as loaded to be able to filter
      final tInitialState = const PublicationLoaded(
        stats: tStats,
        mediaHouses: tMediaHouses,
        transactionsResult: tTransactionsResult,
      );

      const tFilteredTransactionsResult = PublicationTransactionsResult(
        transactions: [],
        publicationCount: '5',
        totalAmount: '500',
      );

      blocTest<PublicationBloc, PublicationState>(
        'emits [PublicationLoaded] with new transactions when filter succeeds',
        seed: () => tInitialState,
        build: () {
          when(() => mockGetPublicationTransactions(any())).thenAnswer(
              (_) async => const Right(tFilteredTransactionsResult));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const FilterPublicationTransactions({'key': 'value'})),
        expect: () => [
          tInitialState.copyWith(
              transactionsResult: tFilteredTransactionsResult),
        ],
      );

      blocTest<PublicationBloc, PublicationState>(
        'emits [PublicationError] when filter fails',
        seed: () => tInitialState,
        build: () {
          when(() => mockGetPublicationTransactions(any())).thenAnswer(
              (_) async => const Left(ServerFailure(message: "Filter Failed")));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const FilterPublicationTransactions({'key': 'value'})),
        expect: () => [
          const PublicationError(message: "Failed to filter transactions"),
        ],
      );
    });
  });
}
