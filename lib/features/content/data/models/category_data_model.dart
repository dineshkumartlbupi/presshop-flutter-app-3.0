import '../../domain/entities/category_data.dart';

class CategoryDataModel extends CategoryData {
  const CategoryDataModel({
    required super.id,
    required super.name,
    super.icon,
    required super.percentage,
    required super.type,
  });

  factory CategoryDataModel.fromJson(Map<String, dynamic> json) {
    return CategoryDataModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
      percentage: json['percentage'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'percentage': percentage,
        'type': type,
      };
}
