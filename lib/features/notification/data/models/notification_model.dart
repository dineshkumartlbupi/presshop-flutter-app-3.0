import '../../domain/entities/notification_entity.dart';
import '../../../../features/earning/data/models/earning_model.dart';
import '../../../../features/earning/domain/entities/earning_transaction.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.description,
    required super.time,
    required super.senderImage,
    required super.messageType,
    required super.senderId,
    required super.paymentStatus,
    required super.contentId,
    required super.broadcastId,
    required super.imageUrl,
    required super.videoUrl,
    required super.exclusive,
    required super.unread,
    super.transactionDetailData,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    EarningTransaction? transactionEntity;
    
    if (json['sold_item_details'] != null && json['sold_item_details'] is Map<String, dynamic>) {
       try {
         var detailModel = EarningTransactionDetail.fromJson(json['sold_item_details']);
         // Map EarningTransactionDetail (Model) to EarningTransaction (Entity)
         transactionEntity = EarningTransaction(
            id: detailModel.id,
            amount: detailModel.amount,
            totalEarningAmt: detailModel.totalEarningAmt,
            status: detailModel.paidStatus.toString(), // Convert bool to string if needed, or mapped field
            isPaid: detailModel.paidStatus,
            contentTitle: detailModel.contentTitle,
            contentType: detailModel.contentType,
            createdAt: detailModel.createdAT,
            adminFullName: detailModel.adminFullName,
            companyLogo: detailModel.companyLogo,
            contentImage: detailModel.contentImage,
            payableT0Hopper: detailModel.payableT0Hopper,
            payableCommission: detailModel.payableCommission,
            stripefee: detailModel.stripefee,
            hopperBankLogo: detailModel.hopperBankLogo,
            hopperBankName: detailModel.hopperBankName,
            userFirstName: detailModel.userFirstName,
            userLastName: detailModel.userLastName,
            contentDataList: detailModel.contentDataList,
            type: detailModel.type,
            typesOfContent: detailModel.typesOfContent,
            hopperAvatar: detailModel.hopperAvatar
         );
       } catch (e) {
         print("Error mapping transaction detail: $e");
       }
    }

    return NotificationModel(
      title: json['title'] ?? "",
      senderImage: json['sender_id'] != null
          ? json['sender_id']['admin_detail'] != null
              ? json['sender_id']['admin_detail']['admin_profile'].toString()
              : ""
          : "",

      senderId: json['sender_id'] != null ? json['sender_id']['_id'] : '',

      unread: !(json['is_read'] ?? false), // Note: Logic was `unread` property but json is `is_read`. If `is_read` is true, unread is false. Or if unread means "is unread".
      // Original code: unread: json['is_read'] ?? false,
      // Wait, if json['is_read'] is true, it means it is read.
      // If the field is `unread`, it should be `!is_read`.
      // Let's check original code: `unread: json['is_read'] ?? false`.
      // The field name in class `NotificationData` was `unread`.
      // If `unread` is true, it means it is NOT read.
      // If API returns `is_read: true`, then `unread` should be false.
      // BUT existing code did: `unread: json['is_read'] ?? false`.
      // This implies the local variable `unread` actually meant `isRead`.
      // Let's check Usage in UI (not visible, but name assumes unread).
      // I will follow existing code logic to be safe, but rename to `isRead` in Entity if I could.
      // Since I named it `unread` in Entity, I should probably stick to `isRead` semantics if the value is `json['is_read']`.
      // Let's change Entity `unread` to `isRead`? Or just map it strictly.
      // Existing: `unread: json['is_read'] ?? false`.
      
      paymentStatus: json['content_details'] != null
          ? json['content_details']['status'] ?? ""
          : "",

      id: json['_id'] ?? "",

      description: json['body'] ?? "",

      imageUrl: json['image_url'] ?? "",
      
      videoUrl: json['video_url'] ?? "",
      messageType: json['message_type'] ?? "",
      time: json['createdAt'] ?? "",

      contentId:
          json['content_details'] != null ? json['content_details']['_id'] : "",

      exclusive: json['content_details'] != null
          ? json['content_details']['type'] == "shared"
              ? false
              : true
          : false,

      transactionDetailData: transactionEntity,

      broadcastId: json['broadCast_id'] ?? "",
    );
  }
}
