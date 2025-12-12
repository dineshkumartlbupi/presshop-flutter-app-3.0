import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/content_category.dart';
import '../repositories/publish_repository.dart';

class GetContentCategories implements UseCase<List<ContentCategory>, NoParams> {
  final PublishRepository repository;

  GetContentCategories(this.repository);

  @override
  Future<Either<Failure, List<ContentCategory>>> call(NoParams params) async {
    return await repository.getCategories();
  }
}
