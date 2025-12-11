import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';

import '../entities/admin_contact_info.dart';

abstract class AccountSettingsRepository {
  Future<Either<Failure, bool>> deleteAccount(Map<String, String> reason);
  Future<Either<Failure, AdminContactInfo>> getAdminContactInfo();
}
