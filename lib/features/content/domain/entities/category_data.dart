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
}
