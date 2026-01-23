import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/authentication/domain/repositories/verification_repository.dart';

class DeleteDocument {
  DeleteDocument(this.repository);
  final VerificationRepository repository;

  Future<Either<Failure, void>> call(String documentId) async {
    return await repository.deleteDocument(documentId);
  }
}
