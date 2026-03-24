import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

class UploadMediaUseCase implements UseCase<String, File> {
  final ChatRepository repository;

  UploadMediaUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(File file) async {
    return await repository.uploadMedia(file);
  }
}
