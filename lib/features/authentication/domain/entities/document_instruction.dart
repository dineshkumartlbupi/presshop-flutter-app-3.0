import 'package:equatable/equatable.dart';

class DocumentInstruction extends Equatable {
  final String id;
  final String name;
  final bool isSelected;

  const DocumentInstruction({
    required this.id,
    required this.name,
    this.isSelected = false,
  });

  @override
  List<Object?> get props => [id, name, isSelected];
}
