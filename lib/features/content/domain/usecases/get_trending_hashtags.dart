import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/hashtag.dart';
import '../repositories/content_repository.dart';

class GetTrendingHashtags implements UseCase<List<Hashtag>, NoParams> {
  final ContentRepository repository;

  GetTrendingHashtags(this.repository);

  @override
  Future<Either<Failure, List<Hashtag>>> call(NoParams params) async {
    return await repository.getTrendingHashtags();
  }
}
