import 'package:presshop/features/authentication/domain/entities/document_instruction.dart';

class DocumentInstructionModel extends DocumentInstruction {
  const DocumentInstructionModel({
    required super.id,
    required super.name,
    super.isSelected,
  });

  factory DocumentInstructionModel.fromJson(Map<String, dynamic> json) {
    return DocumentInstructionModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['doc_name'] ?? json['document_name'] ?? json['name'] ?? '')
          .toString(),
      isSelected: json['isSelected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document_name': name,
      'isSelected': isSelected,
    };
  }
}
