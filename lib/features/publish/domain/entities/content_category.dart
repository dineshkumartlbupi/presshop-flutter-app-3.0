import 'package:equatable/equatable.dart';

class ContentCategory extends Equatable {
  const ContentCategory({
    required this.id,
    required this.name,
    required this.type,
    required this.percentage,
    this.selected = false,
  });
  final String id;
  final String name;
  final String type;
  final String percentage;
  final bool selected;

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'percentage': percentage,
    };
  }
}
