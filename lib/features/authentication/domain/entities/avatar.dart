import 'package:equatable/equatable.dart';

class Avatar extends Equatable {
  final String id;
  final String avatar;
  final String? baseUrl;

  const Avatar({
    required this.id,
    required this.avatar,
    this.baseUrl,
  });

  @override
  List<Object?> get props => [id, avatar, baseUrl];
}
