import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class UploadProfileImage implements UseCase<String, String> {
  UploadProfileImage(this.repository);
  final ProfileRepository repository;

  @override
  Future<Either<Failure, String>> call(String imagePath) async {
    return await repository.uploadProfileImage(imagePath);
  }
}
