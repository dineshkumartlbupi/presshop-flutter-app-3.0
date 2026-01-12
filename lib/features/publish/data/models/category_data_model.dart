import '../../domain/entities/content_category.dart';

class CategoryDataModel extends ContentCategory {
  CategoryDataModel({
    required String id,
    required String name,
    required String type,
    required String percentage,
    bool selected = false,
  }) : super(
            id: id,
            name: name,
            type: type,
            percentage: percentage,
            selected: selected);

  factory CategoryDataModel.fromJson(Map<String, dynamic> json) {
    return CategoryDataModel(
        id: json['_id'] ?? json['id'] ?? "",
        name: json['name'] ?? "",
        type: json['type'] ?? "",
        percentage: json['percentage'] ?? "",
        selected: false);
  }

  @override
  CategoryDataModel copyWith({
    String? id,
    String? name,
    String? type,
    String? percentage,
    bool? selected,
  }) {
    return CategoryDataModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      percentage: percentage ?? this.percentage,
      selected: selected ?? this.selected,
    );
  }
}
