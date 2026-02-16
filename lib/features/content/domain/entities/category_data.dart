import 'package:equatable/equatable.dart';

class CategoryData extends Equatable {
  const CategoryData({
    required this.id,
    required this.name,
    this.icon,
    required this.percentage,
    required this.type,
  });
  final String id;
  final String name;
  final String? icon;
  final String percentage;
  final String type;

  @override
  List<Object?> get props => [
        id,
        name,
        icon,
        percentage,
        type,
      ];

  CategoryData copyWith({
    String? id,
    String? name,
    String? icon,
    String? percentage,
    String? type,
  }) {
    return CategoryData(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      percentage: percentage ?? this.percentage,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'percentage': percentage,
      'type': type,
    };
  }
}
