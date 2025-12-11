import 'package:equatable/equatable.dart';

class Hashtag extends Equatable {
  final String id;
  final String name;
  final int? count;

  const Hashtag({
    required this.id,
    required this.name,
    this.count,
  });

  @override
  List<Object?> get props => [id, name, count];
}
