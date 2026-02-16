import 'package:presshop/features/authentication/domain/entities/document_data.dart';

class DocumentDataModel extends DocumentData {
  const DocumentDataModel({
    required super.id,
    required super.documentName,
    super.isSelected,
  });

  factory DocumentDataModel.fromJson(Map<String, dynamic> json) {
    return DocumentDataModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      documentName:
          (json['doc_name'] ?? json['document_name'] ?? '').toString(),
      isSelected: json['isSelected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document_name': documentName,
      'isSelected': isSelected,
    };
  }
}
