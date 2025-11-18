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
  String imageUrl = "";

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
      this.imageUrl = "",
      //    required this.offerCount,
      required this.exclusive,
      this.broadcastId = ""});

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      title: json['title'] ?? "",
      senderImage: json['sender_id'] != null
          ? json['sender_id']['admin_detail'] != null
              ? json['sender_id']['admin_detail']['admin_profile'].toString()
              : ""
          : "",

      senderId: json['sender_id'] != null ? json['sender_id']['_id'] : '',

      unread: json['is_read'] ?? false,

      paymentStatus: json['content_details'] != null
          ? json['content_details']['status']
          : "",

      id: json['_id'] ?? "",

      // description: json['description'] ?? "",

      description: json['body'] ?? "",

      imageUrl: json['image_url'] ?? "",
      messageType: json['message_type'] ?? "",
      time: json['createdAt'] ?? "",

      // senderImage: "",
      // senderId: "",
      // unread: !(json['is_read'] ?? false),
      // paymentStatus: "",

      contentId:
          json['content_details'] != null ? json['content_details']['_id'] : "",

      exclusive: json['content_details'] != null
          ? json['content_details']['type'] == "shared"
              ? false
              : true
          : false,

      transactionDetailData: json['sold_item_details'] != null
          ? json['sold_item_details'] is Map
              ? EarningTransactionDetail.fromJson(json['sold_item_details'])
              : null
          : null, // not working with this

      // broadcastId: json["broadCast_id"] ?? "",

      // contentId: "",
      // exclusive: false,

      // transactionDetailData: null,  // working

      broadcastId: json['broadCast_id'] ?? "",
    );
  }

  // factory NotificationData.fromJson(Map<String, dynamic> json) {
  //   return NotificationData(
  //       title: json['title'] ?? "",
  //       id: json['_id'] ?? "",
  //       description: json['body'] ?? "",
  //       imageUrl: json['image_url'] ?? "",
  //       messageType: json['message_type'] ?? "",
  //       //  time:json['timestamp_forsorting'] ?? "",
  //       time: json['createdAt'] ?? "",
  //       senderImage: json['sender_id'] != null
  //           ? json['sender_id']['admin_detail'] != null
  //               ? json['sender_id']['admin_detail']['admin_profile'].toString()
  //               : ""
  //           : "",
  //       senderId: json['sender_id'] != null ? json['sender_id']['_id'] : '',
  // unread: json['is_read'] ?? false,
  // paymentStatus: json['content_details'] != null
  //     ? json['content_details']['status']
  //     : "",
  //       contentId: json['content_details'] != null
  //           ? json['content_details']['_id']
  //           : "",
  //       // offerCount: json['content_details']!=null?json['content_details']['offer_content_size']:"0",
  //       exclusive: json['content_details'] != null
  //           ? json['content_details']['type'] == "shared"
  //               ? false
  //               : true
  //           : false,
  //       transactionDetailData: json['sold_item_details'] != null
  //           ? json['sold_item_details'] is Map
  //               ? EarningTransactionDetail.fromJson(json['sold_item_details'])
  //               : null
  //           : null,
  //       broadcastId: json["broadCast_id"] ?? "");
  // }
}

// d":false,"appartment":"","stripe_status":"0","send_reminder":false,"send_statment":false,"bloc
// I/flutter (16492): ----------------FIREBASE CRASHLYTICS----------------



// I/flutter (16492): type 'String' is not a subtype of type 'int'


// I/flutter (16492): #0      new EarningTransactionDetail.fromJson (package:presshop/view/myEarning/earningDataModel.dart:268:46)
// I/flutter (16492): #1      new NotificationData.fromJson (package:presshop/view/menuScreen/Notification/notiticationDataModel.dart:72:44)
// I/flutter (16492): #2      _MyNotificationScreenState.onResponse.<anonymous closure> (package:presshop/view/menuScreen/Notification/MyNotifications.dart:606:59)
