import 'package:presshop/features/authentication/domain/entities/document_instruction.dart';

class DocumentInstructionModel extends DocumentInstruction {
  const DocumentInstructionModel({
    required super.id,
    required super.name,
    super.isSelected,
  });

  factory DocumentInstructionModel.fromJson(Map<String, dynamic> json) {
    return DocumentInstructionModel(
      id: json['_id'] ?? '',
      name: json['document_name'] ?? '',
      isSelected: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'document_name': name,
      'isSelected': isSelected,
    };
  }
}
