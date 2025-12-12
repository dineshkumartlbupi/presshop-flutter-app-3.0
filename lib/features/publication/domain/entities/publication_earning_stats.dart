import 'package:equatable/equatable.dart';

class PublicationEarningStats extends Equatable {
  final String avatar;
  final String publicationCount;
  final String totalEarning;

  const PublicationEarningStats({
    required this.avatar,
    required this.publicationCount,
    required this.totalEarning,
  });

  @override
  List<Object?> get props => [avatar, publicationCount, totalEarning];
}
