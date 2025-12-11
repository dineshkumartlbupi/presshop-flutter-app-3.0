import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/admin_contact_info.dart';
import '../repositories/account_settings_repository.dart';

class GetAdminContactInfo implements UseCase<AdminContactInfo, NoParams> {
  final AccountSettingsRepository repository;

  GetAdminContactInfo(this.repository);

  @override
  Future<Either<Failure, AdminContactInfo>> call(NoParams params) async {
    return await repository.getAdminContactInfo();
  }
}
