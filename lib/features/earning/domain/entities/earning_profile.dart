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

  EarningProfile copyWith({
    String? id,
    String? avatar,
    String? totalEarning,
  }) {
    return EarningProfile(
      id: id ?? this.id,
      avatar: avatar ?? this.avatar,
      totalEarning: totalEarning ?? this.totalEarning,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'avatar': avatar,
      'total_earning': totalEarning,
    };
  }
}
