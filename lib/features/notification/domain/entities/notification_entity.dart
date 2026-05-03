import 'package:equatable/equatable.dart';
import '../../../../features/earning/domain/entities/earning_transaction.dart';


class NotificationEntity extends Equatable {

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.senderImage,
    required this.messageType,
    required this.senderId,
    required this.paymentStatus,
    required this.contentId,
    required this.broadcastId,
    required this.imageUrl,
    required this.videoUrl,
    required this.exclusive,
    required this.unread,
    this.transactionDetailData,
  });
  final String id;
  final String title;
  final String description;
  final String time;
  final String senderImage;
  final String messageType;
  final String senderId;
  final String paymentStatus;
  final String contentId;
  final String broadcastId;
  final String imageUrl;
  final String videoUrl;
  final bool exclusive;
  final bool unread;
  final EarningTransaction? transactionDetailData;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        time,
        senderImage,
        messageType,
        senderId,
        paymentStatus,
        contentId,
        broadcastId,
        imageUrl,
        videoUrl,
        exclusive,
        unread,
        transactionDetailData,
      ];
}

class NotificationsResult extends Equatable {
  
  const NotificationsResult({
    required this.notifications, 
    required this.unreadCount,
    this.alertCount = 0,
  });
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final int alertCount;
  
  @override
  List<Object?> get props => [notifications, unreadCount, alertCount];
}


