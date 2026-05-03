import 'package:presshop/features/authentication/data/models/document_data_model.dart';
import 'package:presshop/features/authentication/data/models/document_instruction_model.dart';
import 'dart:io';

abstract class VerificationRemoteDataSource {
  Future<List<DocumentInstructionModel>> getDocumentInstructions();
  Future<List<DocumentDataModel>> getUploadedDocuments();
  Future<void> uploadDocuments(List<File> files);
  Future<void> deleteDocument(String documentId);
}
