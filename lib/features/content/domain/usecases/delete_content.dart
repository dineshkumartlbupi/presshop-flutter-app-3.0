import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/content_repository.dart';

class DeleteContent implements UseCase<void, String> {
  final ContentRepository repository;

  DeleteContent(this.repository);

  @override
  Future<Either<Failure, void>> call(String contentId) async {
    return await repository.deleteContent(contentId);
  }
}
