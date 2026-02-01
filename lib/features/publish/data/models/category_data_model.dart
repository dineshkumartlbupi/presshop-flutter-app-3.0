import 'package:hive/hive.dart';
import '../../domain/entities/content_category.dart';

part 'category_data_model.g.dart';

@HiveType(typeId: 1)
class CategoryDataModel extends ContentCategory {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String type;
  @HiveField(3)
  final String percentage;
  @HiveField(4)
  final bool selected;

  CategoryDataModel({
    required this.id,
    required this.name,
    required this.type,
    required this.percentage,
    this.selected = false,
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
