import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/features/authentication/domain/usecases/verification/delete_document.dart';
import 'package:presshop/features/authentication/domain/usecases/verification/get_document_instructions.dart';
import 'package:presshop/features/authentication/domain/usecases/verification/get_uploaded_documents.dart';
import 'package:presshop/features/authentication/domain/usecases/verification/upload_document.dart';
import 'package:presshop/features/authentication/presentation/bloc/upload_documents/upload_documents_event.dart';
import 'package:presshop/features/authentication/presentation/bloc/upload_documents/upload_documents_state.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:presshop/features/authentication/domain/entities/document_instruction.dart';
import 'package:presshop/features/authentication/domain/entities/document_data.dart';

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
    final cacheBox = Hive.box('sync_cache');
    final cachedData = cacheBox.get('document_instructions');

    if (cachedData != null && cachedData is List) {
      try {
        final instructions = cachedData
            .map((e) {
              if (e is! Map) return null;
              return DocumentInstruction(
                id: (e['id'] ?? e['_id'] ?? '').toString(),
                name: (e['name'] ?? e['document_name'] ?? '').toString(),
                isSelected: e['isSelected'] ?? false,
              );
            })
            .whereType<DocumentInstruction>()
            .toList();
        if (instructions.isNotEmpty) {
          emit(state.copyWith(
              status: UploadDocumentsStatus.loaded,
              instructions: instructions));
        }
      } catch (e) {
        debugPrint("Error loading document instructions from cache: $e");
      }
    }

    if (state.instructions.isEmpty) {
      emit(state.copyWith(status: UploadDocumentsStatus.loading));
    }

    final result = await getDocumentInstructions();
    result.fold(
      (failure) {
        if (state.instructions.isEmpty) {
          emit(state.copyWith(
              status: UploadDocumentsStatus.failure,
              errorMessage: failure.message));
        }
      },
      (instructions) {
        cacheBox.put('document_instructions',
            instructions.map((e) => e.toJson()).toList());
        emit(state.copyWith(
            status: UploadDocumentsStatus.loaded, instructions: instructions));
      },
    );
  }

  Future<void> _onGetUploadedDocuments(GetUploadedDocumentsEvent event,
      Emitter<UploadDocumentsState> emit) async {
    final cacheBox = Hive.box('sync_cache');
    final cachedData = cacheBox.get('uploaded_documents');

    if (cachedData != null && cachedData is List) {
      try {
        final documents = cachedData
            .map((e) {
              if (e is! Map) return null;
              return DocumentData(
                id: (e['id'] ?? e['_id'] ?? '').toString(),
                documentName:
                    (e['document_name'] ?? e['doc_name'] ?? '').toString(),
                isSelected: e['isSelected'] ?? false,
                status: e['status']?.toString(),
                reason: e['reason']?.toString(),
                createdAt: e['created_at'] != null
                    ? DateTime.tryParse(e['created_at'].toString())
                    : null,
              );
            })
            .whereType<DocumentData>()
            .toList();
        if (documents.isNotEmpty) {
          emit(state.copyWith(
              status: UploadDocumentsStatus.loaded,
              uploadedDocuments: documents));
        }
      } catch (e) {
        debugPrint("Error loading uploaded documents from cache: $e");
      }
    }

    if (state.uploadedDocuments.isEmpty) {
      emit(state.copyWith(status: UploadDocumentsStatus.loading));
    }

    final result = await getUploadedDocuments();
    result.fold(
      (failure) {
        if (state.uploadedDocuments.isEmpty) {
          emit(state.copyWith(
              status: UploadDocumentsStatus.failure,
              errorMessage: failure.message));
        }
      },
      (uploadedDocuments) {
        cacheBox.put('uploaded_documents',
            uploadedDocuments.map((e) => e.toJson()).toList());
        emit(state.copyWith(
            status: UploadDocumentsStatus.loaded,
            uploadedDocuments: uploadedDocuments));
      },
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
