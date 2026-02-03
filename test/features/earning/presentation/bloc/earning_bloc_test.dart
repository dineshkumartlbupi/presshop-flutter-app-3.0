import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/earning/domain/entities/earning_profile.dart';
import 'package:presshop/features/earning/domain/entities/earning_transaction.dart';
import 'package:presshop/features/earning/domain/usecases/get_earning_profile.dart';
import 'package:presshop/features/earning/domain/usecases/get_transactions.dart';
import 'package:presshop/features/earning/domain/usecases/get_commissions.dart';
import 'package:presshop/features/earning/presentation/bloc/earning_bloc.dart';
import 'package:presshop/features/earning/presentation/bloc/earning_event.dart';
import 'package:presshop/features/earning/presentation/bloc/earning_state.dart';

class MockGetEarningProfile extends Mock implements GetEarningProfile {}

class MockGetTransactions extends Mock implements GetTransactions {}

class MockGetCommissions extends Mock implements GetCommissions {}

void main() {
  late EarningBloc bloc;
  late MockGetEarningProfile mockGetEarningProfile;
  late MockGetTransactions mockGetTransactions;
  late MockGetCommissions mockGetCommissions;

  setUp(() {
    mockGetEarningProfile = MockGetEarningProfile();
    mockGetTransactions = MockGetTransactions();
    mockGetCommissions = MockGetCommissions();

    bloc = EarningBloc(
      getEarningProfile: mockGetEarningProfile,
      getTransactions: mockGetTransactions,
      getCommissions: mockGetCommissions,
    );

    registerFallbackValue(GetEarningProfileParams(year: '', month: ''));
    registerFallbackValue(const GetTransactionsParams(params: {}));
  });

  const tEarningProfile = EarningProfile(
    id: '1',
    avatar: 'avatar',
    totalEarning: "100",
  );

  const tTransactionsResult = TransactionsResult(
    transactions: [],
    totalEarning: "100",
  );

  group('FetchEarningDataEvent', () {
    blocTest<EarningBloc, EarningState>(
      'emits [loading, success] when fetching earning data passes',
      build: () {
        when(() => mockGetEarningProfile(any()))
            .thenAnswer((_) async => const Right(tEarningProfile));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const FetchEarningDataEvent(fromDate: '2023', toDate: '01')),
      expect: () => [
        const EarningState(status: EarningStatus.loading),
        const EarningState(
            status: EarningStatus.success, earningData: tEarningProfile),
      ],
    );
  });

  group('FetchTransactionsEvent', () {
    blocTest<EarningBloc, EarningState>(
      'emits [loading, success] when fetching transactions passes',
      build: () {
        when(() => mockGetTransactions(any()))
            .thenAnswer((_) async => const Right(tTransactionsResult));
        return bloc;
      },
      act: (bloc) => bloc.add(
          const FetchTransactionsEvent(limit: 10, offset: 0, filterParams: {})),
      expect: () => [
        isA<EarningState>().having(
            (s) => s.transactionStatus, 'status', EarningStatus.loading),
        isA<EarningState>()
            .having((s) => s.transactionStatus, 'status', EarningStatus.success)
            .having((s) => s.monthlyEarnings, 'earnings', "100"),
      ],
    );
  });
}
