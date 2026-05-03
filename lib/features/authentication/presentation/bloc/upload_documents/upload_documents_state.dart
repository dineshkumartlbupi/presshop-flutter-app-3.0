import 'package:equatable/equatable.dart';
import 'package:presshop/features/authentication/domain/entities/document_data.dart';
import 'package:presshop/features/authentication/domain/entities/document_instruction.dart';

enum UploadDocumentsStatus {
  initial,
  loading,
  loaded,
  failure,
  uploaded,
  deleted
}

class UploadDocumentsState extends Equatable {

  const UploadDocumentsState({
    this.status = UploadDocumentsStatus.initial,
    this.instructions = const [],
    this.uploadedDocuments = const [],
    this.errorMessage = '',
  });
  final UploadDocumentsStatus status;
  final List<DocumentInstruction> instructions;
  final List<DocumentData> uploadedDocuments;
  final String errorMessage;

  UploadDocumentsState copyWith({
    UploadDocumentsStatus? status,
    List<DocumentInstruction>? instructions,
    List<DocumentData>? uploadedDocuments,
    String? errorMessage,
  }) {
    return UploadDocumentsState(
      status: status ?? this.status,
      instructions: instructions ?? this.instructions,
      uploadedDocuments: uploadedDocuments ?? this.uploadedDocuments,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props =>
      [status, instructions, uploadedDocuments, errorMessage];
}
