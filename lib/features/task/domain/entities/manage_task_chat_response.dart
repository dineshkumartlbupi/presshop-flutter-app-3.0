import 'package:equatable/equatable.dart';
import 'package:presshop/features/task/data/models/manage_task_chat_model.dart';

class ManageTaskChatResponse extends Equatable {
  final List<ManageTaskChatModel> chatList;
  final int offerCount;
  final int purchaseCount;
  final int viewCount;
  final String? totalEarning;

  const ManageTaskChatResponse({
    required this.chatList,
    required this.offerCount,
    required this.purchaseCount,
    required this.viewCount,
    this.totalEarning,
  });

  @override
  List<Object?> get props => [chatList, offerCount, purchaseCount, viewCount, totalEarning];
}
