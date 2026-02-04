import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/account_settings_repository.dart';

class DeleteAccount implements UseCase<bool, DeleteAccountParams> {

  DeleteAccount(this.repository);
  final AccountSettingsRepository repository;

  @override
  Future<Either<Failure, bool>> call(DeleteAccountParams params) async {
    return await repository.deleteAccount(params.reason);
  }
}

class DeleteAccountParams extends Equatable {

  const DeleteAccountParams({required this.reason});
  final Map<String, String> reason;

  @override
  List<Object> get props => [reason];
}
