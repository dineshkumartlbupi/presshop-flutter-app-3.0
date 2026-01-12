import 'package:equatable/equatable.dart';

class ContentCategory extends Equatable {
  final String id;
  final String name;
  final String type;
  final String percentage;
  final bool selected;

  const ContentCategory({
    required this.id,
    required this.name,
    required this.type,
    required this.percentage,
    this.selected = false,
  });

  @override
  List<Object?> get props => [id, name, type, percentage, selected];

  ContentCategory copyWith({
    String? id,
    String? name,
    String? type,
    String? percentage,
    bool? selected,
  }) {
    return ContentCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      percentage: percentage ?? this.percentage,
      selected: selected ?? this.selected,
    );
  }
}
