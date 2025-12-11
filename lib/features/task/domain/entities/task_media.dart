import 'package:equatable/equatable.dart';

class TaskMedia extends Equatable {
  final String id;
  final String type;
  final String thumbnail;
  final String imageVideoUrl;
  final bool paidStatus;
  final String amount;
  final bool paidStatusToHopper;
  final String paidAmount;
  final String payableAmount;
  final String commitionAmount;

  const TaskMedia({
    required this.id,
    required this.type,
    required this.thumbnail,
    required this.imageVideoUrl,
    required this.paidStatus,
    required this.amount,
    required this.paidStatusToHopper,
    required this.paidAmount,
    required this.payableAmount,
    required this.commitionAmount,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        thumbnail,
        imageVideoUrl,
        paidStatus,
        amount,
        paidStatusToHopper,
        paidAmount,
        payableAmount,
        commitionAmount,
      ];
}
