import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/features/authentication/domain/usecases/verification/delete_document.dart';
import 'package:presshop/features/authentication/domain/usecases/verification/get_document_instructions.dart';
import 'package:presshop/features/authentication/domain/usecases/verification/get_uploaded_documents.dart';
import 'package:presshop/features/authentication/domain/usecases/verification/upload_document.dart';
import 'package:presshop/features/authentication/presentation/bloc/upload_documents/upload_documents_event.dart';
import 'package:presshop/features/authentication/presentation/bloc/upload_documents/upload_documents_state.dart';

class UploadDocumentsBloc
    extends Bloc<UploadDocumentsEvent, UploadDocumentsState> {

  UploadDocumentsBloc({
    required this.getDocumentInstructions,
    required this.getUploadedDocuments,
    required this.uploadDocument,
    required this.deleteDocument,
  }) : super(const UploadDocumentsState()) {
    on<GetDocumentInstructionsEvent>(_onGetDocumentInstructions);
    on<GetUploadedDocumentsEvent>(_onGetUploadedDocuments);
    on<UploadFilesEvent>(_onUploadFiles);
    on<DeleteDocumentEvent>(_onDeleteDocument);
  }
  final GetDocumentInstructions getDocumentInstructions;
  final GetUploadedDocuments getUploadedDocuments;
  final UploadDocument uploadDocument;
  final DeleteDocument deleteDocument;

  Future<void> _onGetDocumentInstructions(GetDocumentInstructionsEvent event,
      Emitter<UploadDocumentsState> emit) async {
    emit(state.copyWith(status: UploadDocumentsStatus.loading));
    final result = await getDocumentInstructions();
    result.fold(
      (failure) => emit(state.copyWith(
          status: UploadDocumentsStatus.failure,
          errorMessage: failure.message)),
      (instructions) => emit(state.copyWith(
          status: UploadDocumentsStatus.loaded, instructions: instructions)),
    );
  }

  Future<void> _onGetUploadedDocuments(GetUploadedDocumentsEvent event,
      Emitter<UploadDocumentsState> emit) async {
    emit(state.copyWith(status: UploadDocumentsStatus.loading));
    final result = await getUploadedDocuments();
    result.fold(
      (failure) => emit(state.copyWith(
          status: UploadDocumentsStatus.failure,
          errorMessage: failure.message)),
      (uploadedDocuments) => emit(state.copyWith(
          status: UploadDocumentsStatus.loaded,
          uploadedDocuments: uploadedDocuments)),
    );
  }

  Future<void> _onUploadFiles(
      UploadFilesEvent event, Emitter<UploadDocumentsState> emit) async {
    emit(state.copyWith(status: UploadDocumentsStatus.loading));
    final result = await uploadDocument(event.files);
    result.fold(
      (failure) => emit(state.copyWith(
          status: UploadDocumentsStatus.failure,
          errorMessage: failure.message)),
      (_) {
        // Trigger reload of documents after successful upload
        add(GetUploadedDocumentsEvent());
        emit(state.copyWith(status: UploadDocumentsStatus.uploaded));
      },
    );
  }

  Future<void> _onDeleteDocument(
      DeleteDocumentEvent event, Emitter<UploadDocumentsState> emit) async {
    emit(state.copyWith(status: UploadDocumentsStatus.loading));
    final result = await deleteDocument(event.documentId);
    result.fold(
      (failure) => emit(state.copyWith(
          status: UploadDocumentsStatus.failure,
          errorMessage: failure.message)),
      (_) {
        emit(state.copyWith(status: UploadDocumentsStatus.deleted));
        // Trigger reload of documents after successful deletion
        add(GetUploadedDocumentsEvent());
      },
    );
  }
}
