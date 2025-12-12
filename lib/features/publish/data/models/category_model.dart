import '../../domain/entities/content_category.dart';

class CategoryModel extends ContentCategory {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.type,
    required super.percentage,
    required super.selected,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? "",
      name: json['name'] ?? "",
      type: json['type'] ?? "",
      percentage: json['percentage']?.toString() ?? "",
      selected: false,
    );
  }
}
