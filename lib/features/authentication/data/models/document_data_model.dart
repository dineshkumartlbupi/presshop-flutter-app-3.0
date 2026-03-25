import 'package:presshop/features/authentication/domain/entities/document_data.dart';

class DocumentDataModel extends DocumentData {
  const DocumentDataModel({
    required super.id,
    required super.documentName,
    required super.documentUrl,
    super.isSelected,
    super.status,
    super.reason,
    super.createdAt,
  });

  factory DocumentDataModel.fromJson(Map<String, dynamic> json) {
    return DocumentDataModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      documentName:
          (json['doc_name'] ?? json['document_name'] ?? '').toString(),
      documentUrl: (json['doc_url'] ?? json['document_url'] ?? '').toString(),
      isSelected: json['isSelected'] ?? false,
      status: json['status']?.toString(),
      reason: json['remarks'] ?? json['reason'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
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
