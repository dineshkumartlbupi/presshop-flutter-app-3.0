import 'package:equatable/equatable.dart';
import 'package:presshop/features/bank/domain/entities/bank_detail.dart';

abstract class BankState extends Equatable {
  const BankState();

  @override
  List<Object> get props => [];
}

class BankInitial extends BankState {}

class BankLoading extends BankState {}

class BanksLoaded extends BankState {
  final List<BankDetail> banks;

  const BanksLoaded(this.banks);

  @override
  List<Object> get props => [banks];
}

class BankError extends BankState {
  final String message;

  const BankError(this.message);

  @override
  List<Object> get props => [message];
}

class BankDeleted extends BankState {}

class BankDefaultSet extends BankState {}

class StripeUrlLoaded extends BankState {
  final String url;

  const StripeUrlLoaded(this.url);

  @override
  List<Object> get props => [url];
}
