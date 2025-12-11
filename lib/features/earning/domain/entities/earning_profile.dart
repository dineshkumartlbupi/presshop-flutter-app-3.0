import 'package:equatable/equatable.dart';

class EarningProfile extends Equatable {
  final String id;
  final String avatar;
  final String totalEarning;

  const EarningProfile({
    required this.id,
    required this.avatar,
    required this.totalEarning,
  });

  @override
  List<Object?> get props => [id, avatar, totalEarning];
}
