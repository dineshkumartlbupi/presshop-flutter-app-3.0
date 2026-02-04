import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class UploadDocumentsEvent extends Equatable {
  const UploadDocumentsEvent();

  @override
  List<Object?> get props => [];
}

class GetDocumentInstructionsEvent extends UploadDocumentsEvent {}

class GetUploadedDocumentsEvent extends UploadDocumentsEvent {}

class UploadFilesEvent extends UploadDocumentsEvent {
  const UploadFilesEvent(this.files);
  final List<File> files;

  @override
  List<Object?> get props => [files];
}

class DeleteDocumentEvent extends UploadDocumentsEvent {
  const DeleteDocumentEvent(this.documentId);
  final String documentId;

  @override
  List<Object?> get props => [documentId];
}
