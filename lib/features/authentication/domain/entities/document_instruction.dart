import 'package:equatable/equatable.dart';

class DocumentInstruction extends Equatable {
  const DocumentInstruction({
    required this.id,
    required this.name,
    this.isSelected = false,
  });
  final String id;
  final String name;
  final bool isSelected;

  @override
  List<Object?> get props => [id, name, isSelected];

  DocumentInstruction copyWith({
    String? id,
    String? name,
    bool? isSelected,
  }) {
    return DocumentInstruction(
      id: id ?? this.id,
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isSelected': isSelected,
    };
  }
}
