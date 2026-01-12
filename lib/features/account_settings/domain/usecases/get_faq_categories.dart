import 'package:dartz/dartz.dart';

import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../../../publish/domain/entities/content_category.dart';
import '../repositories/account_settings_repository.dart';

class GetFAQCategories implements UseCase<List<ContentCategory>, NoParams> {
  final AccountSettingsRepository repository;

  GetFAQCategories(this.repository);

  @override
  Future<Either<Failure, List<ContentCategory>>> call(NoParams params) async {
    return await repository.getFAQCategories();
  }
}
