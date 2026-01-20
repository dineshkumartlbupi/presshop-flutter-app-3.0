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
        isUser: json['is_user'] == true || json['is_user'] == "true",
        isNavigate: (json['message'] ?? "")
            .toString()
            .contains("handing you over to a real person"),
        time: json['createdAt'] ?? json['time'] ?? "");
  }
}
