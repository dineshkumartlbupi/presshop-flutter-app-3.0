import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/content_repository.dart';

class UploadMedia implements UseCase<List<String>, List<String>> {
  UploadMedia(this.repository);
  final ContentRepository repository;

  @override
  Future<Either<Failure, List<String>>> call(List<String> filePaths) async {
    return await repository.uploadMedia(filePaths);
  }
}
