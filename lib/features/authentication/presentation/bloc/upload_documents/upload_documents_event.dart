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
  final List<File> files;
  const UploadFilesEvent(this.files);

  @override
  List<Object?> get props => [files];
}

class DeleteDocumentEvent extends UploadDocumentsEvent {
  final String documentId;
  const DeleteDocumentEvent(this.documentId);

  @override
  List<Object?> get props => [documentId];
}
