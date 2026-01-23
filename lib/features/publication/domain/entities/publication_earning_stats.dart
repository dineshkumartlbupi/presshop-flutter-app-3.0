import 'package:equatable/equatable.dart';

class PublicationEarningStats extends Equatable {
  const PublicationEarningStats({
    required this.avatar,
    required this.publicationCount,
    required this.totalEarning,
  });
  final String avatar;
  final String publicationCount;
  final String totalEarning;

  @override
  List<Object?> get props => [avatar, publicationCount, totalEarning];
}
