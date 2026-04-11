import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

class UploadMediaUseCase implements UseCase<String, File> {

  UploadMediaUseCase(this.repository);
  final ChatRepository repository;

  @override
  Future<Either<Failure, String>> call(File file) async {
    return await repository.uploadMedia(file);
  }
}
