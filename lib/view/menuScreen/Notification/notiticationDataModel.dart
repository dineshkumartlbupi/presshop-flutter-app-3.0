import '../../myEarning/earningDataModel.dart';

class NotificationData {
  String id = "";
  String title = "";
  String description = "";
  String time = "";
  String senderImage = "";
  String messageType = "";
  String senderId = "";
  String paymentStatus = "";
  String contentId = "";
  String broadcastId = "";

  //String offerCount = "";
  bool exclusive = false;
  bool unread = false;
  EarningTransactionDetail? transactionDetailData;

  NotificationData(
      {required this.title,
      required this.id,
      required this.description,
      required this.messageType,
      required this.time,
      required this.senderImage,
      required this.senderId,
      required this.unread,
      required this.paymentStatus,
      required this.contentId,
      required this.transactionDetailData,
      //    required this.offerCount,
      required this.exclusive,
      this.broadcastId = ""});

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
        title: json['title'] ?? "",
        id: json['_id'] ?? "",
        description: json['body'] ?? "",
        messageType: json['message_type'] ?? "",
        //  time:json['timestamp_forsorting'] ?? "",
        time: json['createdAt'] ?? "",
        senderImage: json['sender_id'] != null
            ? json['sender_id']['admin_detail'] != null
                ? json['sender_id']['admin_detail']['admin_profile'].toString()
                : ""
            : "",
        senderId: json['sender_id'] != null ? json['sender_id']['_id'] : '',
        unread: json['is_read'] ?? false,
        paymentStatus: json['content_details'] != null ? json['content_details']['status'] : "",
        contentId: json['content_details'] != null ? json['content_details']['_id'] : "",
        // offerCount: json['content_details']!=null?json['content_details']['offer_content_size']:"0",
        exclusive: json['content_details'] != null
            ? json['content_details']['type'] == "shared"
                ? false
                : true
            : false,
        transactionDetailData: json['sold_item_details'] != null ? json['sold_item_details'] is Map? EarningTransactionDetail.fromJson(json['sold_item_details']) : null:null,
        broadcastId: json["broadCast_id"] ?? "");
  }
}
