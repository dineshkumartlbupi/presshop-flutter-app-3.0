import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/authentication/domain/entities/document_data.dart';
import 'package:presshop/features/authentication/domain/entities/document_instruction.dart';

abstract class VerificationRepository {
  Future<Either<Failure, List<DocumentInstruction>>> getDocumentInstructions();
  Future<Either<Failure, List<DocumentData>>> getUploadedDocuments();
  Future<Either<Failure, void>> uploadDocuments(List<File> files);
  Future<Either<Failure, void>> deleteDocument(String documentId);
}
