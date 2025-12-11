class ChatModel {
  String message = "";
  String time = "";
  bool isUser = false;
  bool isNavigate = true;
  bool hasShownFirstFailMsg = false;

  ChatModel(
      {required this.message,
      required this.isUser,
      required this.time,
      required this.isNavigate,
      this.hasShownFirstFailMsg = false});

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
        message: json['message'] ?? "",
        isUser: json['is_user'] == true ? true : false,
        isNavigate: false,
        time: json['time']);
  }
}

