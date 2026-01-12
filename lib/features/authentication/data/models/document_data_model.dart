import 'package:presshop/features/authentication/domain/entities/document_data.dart';

class DocumentDataModel extends DocumentData {
  const DocumentDataModel({
    required super.id,
    required super.documentName,
    super.isSelected,
  });

  factory DocumentDataModel.fromJson(Map<String, dynamic> json) {
    return DocumentDataModel(
      id: json['_id'] ?? '',
      documentName: json['doc_name'] ?? '',
      isSelected: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'doc_name': documentName,
      'isSelected': isSelected,
    };
  }
}
