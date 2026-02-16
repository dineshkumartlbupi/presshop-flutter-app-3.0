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
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      icon: json['icon']?.toString(),
      percentage: (json['percentage'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
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
