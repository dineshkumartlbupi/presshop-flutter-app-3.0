import 'package:equatable/equatable.dart';

class DocumentData extends Equatable {
  const DocumentData({
    required this.id,
    required this.documentName,
    required this.documentUrl,
    this.isSelected = false,
    this.status,
    this.reason,
    this.createdAt,
  });
  final String id;
  final String documentName;
  final String documentUrl;
  final String? status;
  final String? reason;
  final DateTime? createdAt;
  final bool isSelected;

  @override
  List<Object?> get props =>
      [id, documentName, documentUrl, isSelected, status, reason, createdAt];

  DocumentData copyWith({
    String? id,
    String? documentName,
    String? documentUrl,
    bool? isSelected,
    String? status,
    String? reason,
    DateTime? createdAt,
  }) {
    return DocumentData(
      id: id ?? this.id,
      documentName: documentName ?? this.documentName,
      documentUrl: documentUrl ?? this.documentUrl,
      isSelected: isSelected ?? this.isSelected,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document_name': documentName,
      'document_url': documentUrl,
      'isSelected': isSelected,
      'status': status,
      'reason': reason,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
