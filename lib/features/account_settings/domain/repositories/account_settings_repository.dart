import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';

import '../entities/admin_contact_info.dart';
import '../entities/faq.dart';
import '../../../publish/domain/entities/content_category.dart';

abstract class AccountSettingsRepository {
  Future<Either<Failure, bool>> deleteAccount(Map<String, String> reason);
  Future<Either<Failure, AdminContactInfo>> getAdminContactInfo();
  Future<Either<Failure, List<FAQ>>> getFAQs(
      String category, int offset, int limit);
  Future<Either<Failure, List<FAQ>>> getPriceTips(
      String category, int offset, int limit);
  Future<Either<Failure, List<ContentCategory>>> getFAQCategories(String type);
}
