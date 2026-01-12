import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/authentication/domain/entities/document_instruction.dart';
import 'package:presshop/features/authentication/domain/repositories/verification_repository.dart';

class GetDocumentInstructions {
  final VerificationRepository repository;

  GetDocumentInstructions(this.repository);

  Future<Either<Failure, List<DocumentInstruction>>> call() async {
    return await repository.getDocumentInstructions();
  }
}
