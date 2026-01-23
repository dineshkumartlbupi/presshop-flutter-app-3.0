import 'package:equatable/equatable.dart';

class Hashtag extends Equatable {
  const Hashtag({
    required this.id,
    required this.name,
    this.count,
  });
  final String id;
  final String name;
  final int? count;

  @override
  List<Object?> get props => [id, name, count];
}
