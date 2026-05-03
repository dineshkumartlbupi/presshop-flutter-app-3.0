import 'package:dartz/dartz.dart';

import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../../data/models/category_data_model.dart';
import '../repositories/tutorials_repository.dart';

class GetTutorialCategories
    implements UseCase<List<CategoryDataModel>, NoParams> {

  GetTutorialCategories(this.repository);
  final TutorialsRepository repository;

  @override
  Future<Either<Failure, List<CategoryDataModel>>> call(NoParams params) async {
    return await repository.getCategories();
  }
}
