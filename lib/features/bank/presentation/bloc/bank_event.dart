import 'package:equatable/equatable.dart';

abstract class BankEvent extends Equatable {
  const BankEvent();

  @override
  List<Object> get props => [];
}

class FetchBanksEvent extends BankEvent {}

class DeleteBankEvent extends BankEvent {

  const DeleteBankEvent({required this.id, required this.stripeBankId});
  final String id;
  final String stripeBankId;

  @override
  List<Object> get props => [id, stripeBankId];
}

class SetDefaultBankEvent extends BankEvent {

  const SetDefaultBankEvent({required this.stripeBankId, required this.isDefault});
  final String stripeBankId;
  final bool isDefault;

  @override
  List<Object> get props => [stripeBankId, isDefault];
}

class GetStripeUrlEvent extends BankEvent {}
