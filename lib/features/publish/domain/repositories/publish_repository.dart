import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/content_category.dart';
import '../entities/charity.dart';
import '../entities/tutorial.dart';

abstract class PublishRepository {
  Future<Either<Failure, List<ContentCategory>>> getCategories();
  Future<Either<Failure, List<ContentCategory>>> getTutorialCategories();
  Future<Either<Failure, List<Charity>>> getCharities(int offset, int limit);
  Future<Either<Failure, List<Tutorial>>> getTutorials(String category, int offset, int limit);
  Future<Either<Failure, void>> addViewCount(String tutorialId);
  Future<Either<Failure, Map<String, String>>> getShareExclusivePrice();
  Future<Either<Failure, void>> submitContent(Map<String, dynamic> params, List<String> filePaths);
}
