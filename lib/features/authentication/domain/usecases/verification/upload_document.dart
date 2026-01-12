import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/authentication/domain/repositories/verification_repository.dart';

class UploadDocument {
  final VerificationRepository repository;

  UploadDocument(this.repository);

  Future<Either<Failure, void>> call(List<File> files) async {
    return await repository.uploadDocuments(files);
  }
}
