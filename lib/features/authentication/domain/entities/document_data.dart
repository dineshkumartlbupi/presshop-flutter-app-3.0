import 'package:equatable/equatable.dart';

class DocumentData extends Equatable {
  final String id;
  final String documentName;
  final String? status;
  final String? reason;
  final DateTime? createdAt;
  final bool isSelected;

  const DocumentData({
    required this.id,
    required this.documentName,
    this.isSelected = false,
    this.status,
    this.reason,
    this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, documentName, isSelected, status, reason, createdAt];
}
