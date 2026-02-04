import 'package:equatable/equatable.dart';

class DocumentData extends Equatable {

  const DocumentData({
    required this.id,
    required this.documentName,
    this.isSelected = false,
    this.status,
    this.reason,
    this.createdAt,
  });
  final String id;
  final String documentName;
  final String? status;
  final String? reason;
  final DateTime? createdAt;
  final bool isSelected;

  @override
  List<Object?> get props =>
      [id, documentName, isSelected, status, reason, createdAt];
}
