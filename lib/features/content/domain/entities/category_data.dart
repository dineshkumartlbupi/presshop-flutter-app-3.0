import 'package:equatable/equatable.dart';

class CategoryData extends Equatable {
  final String id;
  final String name;
  final String? icon;
  final String percentage;
  final String type;

  const CategoryData({
    required this.id,
    required this.name,
    this.icon,
    required this.percentage,
    required this.type,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        icon,
        percentage,
        type,
      ];
}
