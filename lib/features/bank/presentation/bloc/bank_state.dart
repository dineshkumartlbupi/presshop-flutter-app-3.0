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

  const BanksLoaded(this.banks);
  final List<BankDetail> banks;

  @override
  List<Object> get props => [banks];
}

class BankError extends BankState {

  const BankError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

class BankDeleted extends BankState {}

class BankDefaultSet extends BankState {}

class StripeUrlLoaded extends BankState {

  const StripeUrlLoaded(this.url);
  final String url;

  @override
  List<Object> get props => [url];
}
