import 'package:equatable/equatable.dart';

class Avatar extends Equatable {
  final String id;
  final String avatar;

  const Avatar({required this.id, required this.avatar});

  @override
  List<Object?> get props => [id, avatar];
}
