import 'package:equatable/equatable.dart';

abstract class BankEvent extends Equatable {
  const BankEvent();

  @override
  List<Object> get props => [];
}

class FetchBanksEvent extends BankEvent {}

class DeleteBankEvent extends BankEvent {
  final String id;
  final String stripeBankId;

  const DeleteBankEvent({required this.id, required this.stripeBankId});

  @override
  List<Object> get props => [id, stripeBankId];
}

class SetDefaultBankEvent extends BankEvent {
  final String stripeBankId;
  final bool isDefault;

  const SetDefaultBankEvent({required this.stripeBankId, required this.isDefault});

  @override
  List<Object> get props => [stripeBankId, isDefault];
}

class GetStripeUrlEvent extends BankEvent {}
