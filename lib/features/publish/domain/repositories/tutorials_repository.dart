import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/tutorials_model.dart';
import '../../data/models/category_data_model.dart';

abstract class TutorialsRepository {
  Future<Either<Failure, List<TutorialsModel>>> getTutorials(
      String category, int offset, int limit);
  Future<Either<Failure, List<CategoryDataModel>>> getCategories();
  Future<Either<Failure, void>> addViewCount(String tutorialId);
}
