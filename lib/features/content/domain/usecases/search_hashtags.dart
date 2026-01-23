import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/hashtag.dart';
import '../repositories/content_repository.dart';

class SearchHashtags implements UseCase<List<Hashtag>, String> {
  SearchHashtags(this.repository);
  final ContentRepository repository;

  @override
  Future<Either<Failure, List<Hashtag>>> call(String query) async {
    return await repository.searchHashtags(query);
  }
}
