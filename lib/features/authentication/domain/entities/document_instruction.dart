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
}
