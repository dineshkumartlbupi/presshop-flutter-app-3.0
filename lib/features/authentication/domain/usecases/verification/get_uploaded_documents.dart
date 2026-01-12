import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/authentication/domain/entities/document_data.dart';
import 'package:presshop/features/authentication/domain/repositories/verification_repository.dart';

class GetUploadedDocuments {
  final VerificationRepository repository;

  GetUploadedDocuments(this.repository);

  Future<Either<Failure, List<DocumentData>>> call() async {
    return await repository.getUploadedDocuments();
  }
}
