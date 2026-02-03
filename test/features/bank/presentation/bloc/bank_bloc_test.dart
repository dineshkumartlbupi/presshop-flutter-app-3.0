import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/bank/domain/usecases/delete_bank.dart';
import 'package:presshop/features/bank/domain/usecases/get_banks.dart';
import 'package:presshop/features/bank/domain/usecases/get_stripe_onboarding_url.dart';
import 'package:presshop/features/bank/domain/usecases/set_default_bank.dart';
import 'package:presshop/features/bank/presentation/bloc/bank_bloc.dart';
import 'package:presshop/features/bank/presentation/bloc/bank_event.dart';
import 'package:presshop/features/bank/presentation/bloc/bank_state.dart';

class MockGetBanks extends Mock implements GetBanks {}

class MockDeleteBank extends Mock implements DeleteBank {}

class MockSetDefaultBank extends Mock implements SetDefaultBank {}

class MockGetStripeOnboardingUrl extends Mock
    implements GetStripeOnboardingUrl {}

void main() {
  late BankBloc bloc;
  late MockGetBanks mockGetBanks;
  late MockDeleteBank mockDeleteBank;
  late MockSetDefaultBank mockSetDefaultBank;
  late MockGetStripeOnboardingUrl mockGetStripeOnboardingUrl;

  setUp(() {
    mockGetBanks = MockGetBanks();
    mockDeleteBank = MockDeleteBank();
    mockSetDefaultBank = MockSetDefaultBank();
    mockGetStripeOnboardingUrl = MockGetStripeOnboardingUrl();

    bloc = BankBloc(
      getBanks: mockGetBanks,
      deleteBank: mockDeleteBank,
      setDefaultBank: mockSetDefaultBank,
      getStripeOnboardingUrl: mockGetStripeOnboardingUrl,
    );

    registerFallbackValue(NoParams());
    registerFallbackValue(const DeleteBankParams(id: '', stripeBankId: ''));
    registerFallbackValue(
        const SetDefaultBankParams(stripeBankId: '', isDefault: false));
  });

  group('FetchBanksEvent', () {
    blocTest<BankBloc, BankState>(
      'emits [BankLoading, BanksLoaded] when fetching banks passes',
      build: () {
        when(() => mockGetBanks(any()))
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchBanksEvent()),
      expect: () => [
        BankLoading(),
        const BanksLoaded([]),
      ],
    );
  });

  group('DeleteBankEvent', () {
    blocTest<BankBloc, BankState>(
      'emits [BankLoading, BankDeleted] and triggers FetchBanksEvent when deletion passes',
      build: () {
        when(() => mockDeleteBank(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetBanks(any()))
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const DeleteBankEvent(id: '1', stripeBankId: 's1')),
      expect: () => [
        BankLoading(),
        BankDeleted(),
        BankLoading(),
        const BanksLoaded([]),
      ],
    );
  });

  group('GetStripeUrlEvent', () {
    blocTest<BankBloc, BankState>(
      'emits [BankLoading, StripeUrlLoaded] when getting url passes',
      build: () {
        when(() => mockGetStripeOnboardingUrl(any()))
            .thenAnswer((_) async => const Right('http://stripe.com'));
        return bloc;
      },
      act: (bloc) => bloc.add(GetStripeUrlEvent()),
      expect: () => [
        BankLoading(),
        const StripeUrlLoaded('http://stripe.com'),
      ],
    );
  });
}
