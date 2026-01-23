import 'package:equatable/equatable.dart';

class EarningProfile extends Equatable {
  const EarningProfile({
    required this.id,
    required this.avatar,
    required this.totalEarning,
  });
  final String id;
  final String avatar;
  final String totalEarning;

  @override
  List<Object?> get props => [id, avatar, totalEarning];
}
