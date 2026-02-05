import 'package:equatable/equatable.dart';

class Avatar extends Equatable {

  const Avatar({
    required this.id,
    required this.avatar,
  });
  final String id;
  final String avatar;

  @override
  List<Object?> get props => [id, avatar];
}
