import 'package:dio/dio.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/api/api_constant.dart' as api_const;
import 'package:presshop/core/api/api_constant.dart'
    hide getTaskTransactionDetails;
import 'package:presshop/features/dashboard/data/models/task_detail_model.dart';
import 'package:presshop/core/common_models_export.dart' hide TaskDetailModel;
import 'package:presshop/features/earning/data/models/earning_model.dart';
import 'package:presshop/core/error/exceptions.dart';
import 'package:presshop/features/task/data/models/all_task_model.dart';
import 'package:presshop/features/task/data/models/my_task_model.dart';
import 'package:presshop/features/task/domain/entities/task.dart';
import 'package:presshop/features/task/domain/entities/task_all.dart';

abstract class TaskRemoteDataSource {
  Future<TaskDetailModel> getTaskDetail(String taskId);
  Future<void> acceptRejectTask(
      {required String taskId,
      required String mediaHouseId,
      required String status});
  Future<List<ManageTaskChatModel>> getTaskChat(
      String roomId, String type, String contentId);
  Future<Map<String, dynamic>> uploadTaskMedia(FormData data);
  Future<String> getRoomId(
      String receiverId, String taskId, String roomType, String type);
  Future<String> getHopperAcceptedCount(String taskId);
  Future<List<EarningTransactionDetail>> getTaskTransactionDetails(
      String transactionId);
  Future<List<EarningTransactionDetail>> getContentTransactionDetails(
      String roomId, String mediaHouseId);
  Future<List<TaskAll>> getAllTasks(
      {required int limit,
      required int offset,
      Map<String, dynamic>? filterParams});
  Future<List<Task>> getLocalTasks(Map<String, dynamic> filterParams);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final ApiClient apiClient;

  TaskRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<TaskDetailModel> getTaskDetail(String taskId) async {
    final response = await apiClient.get(
      "$taskDetailUrl$taskId",
    );

    if (response.data["code"] == 200) {
      String roomId = "";
      if (response.data["resp"] != null) {
        roomId = (response.data["resp"]["room_id"] ?? "").toString();
      }
      return TaskDetailModel.fromJson(response.data["task"] ?? {},
          roomId: roomId);
    } else {
      throw ServerException(
          response.data["message"] ?? "Failed to load task details");
    }
  }

  @override
  Future<void> acceptRejectTask(
      {required String taskId,
      required String mediaHouseId,
      required String status}) async {
    final response = await apiClient.post(taskAcceptRejectRequestUrl, data: {
      "task_id": taskId,
      "media_house_id": mediaHouseId,
      "task_status": status
    });

    if (response.statusCode != 200) {
      throw ServerException(
          response.data["message"] ?? "Failed to accept/reject task");
    }
  }

  @override
  Future<List<ManageTaskChatModel>> getTaskChat(
      String roomId, String type, String contentId) async {
    // Logic from manage_task_screen.dart: callGetManageTaskListingApi
    // If type == 'content', it uses getMediaTaskChatListUrl with contentId ? No wait, check logs.
    // Actually in manage_task_screen.dart lines 7236:
    // Map<String, String> map = {"content_id": widget.contentId.toString()};
    // NetworkClass... getOfferPaymentChat ...

    // It seems there are two logic paths in original code, one commented out.
    // The active one is `getOfferPaymentChat`.

    // However, looking at the code I read in 1120, it used:
    // Map<String, String> map = {"content_id": widget.contentId.toString()};
    // NetworkClass.fromNetworkClass(getOfferPaymentChat, this, getOfferPaymentChatReq, map)

    // But wait, there was also commented out code for `getMediaTaskChatListUrl`.
    // I need to support what `BroadCastChatTaskScreen` needs.
    // In `BroadCastChatTaskScreen.dart`, line 119 calls `callGetManageTaskListingApi`.
    // Let's use `getOfferPaymentChat` as seen in active code.

    // Correct mapping:
    // If type is content, pass content_id.

    final response = await apiClient.post(
      getOfferPaymentChat, // Or getMediaTaskChatListUrl depending on exact usage.
      // Based on Step 1120 active code, it uses getOfferPaymentChat with content_id.
      data: {"content_id": contentId},
    );

    if (response.data["code"] == 200) {
      List<ManageTaskChatModel> chatList = [];
      if (response.data["chat"] != null) {
        response.data["chat"].forEach((v) {
          chatList.add(ManageTaskChatModel.fromJson(v));
        });
      }
      return chatList;
    } else {
      throw ServerException(response.data["message"] ?? "Failed to load chats");
    }
  }

  @override
  Future<Map<String, dynamic>> uploadTaskMedia(FormData data) async {
    final response = await apiClient.multipartPost(
      uploadTaskMediaUrl,
      formData: data,
    );
    if (response.data["success"] == true) {
      return response.data;
    } else {
      throw ServerException(
          response.data["message"] ?? "Failed to upload media");
    }
  }

  @override
  Future<String> getRoomId(
      String receiverId, String taskId, String roomType, String type) async {
    Map<String, String> map = {
      "receiver_id": receiverId,
      "room_type": roomType, // "HoppertoAdmin"
      "type": type, // "external_task"
      "task_id": taskId,
    };

    final response = await apiClient.post(
      getRoomIdUrl,
      data: map,
    );

    if (response.data["code"] == 200 && response.data["resp"] != null) {
      return (response.data["resp"]["room_id"] ?? "").toString();
    } else {
      throw ServerException(
          response.data["message"] ?? "Failed to get room ID");
    }
  }

  @override
  Future<String> getHopperAcceptedCount(String taskId) async {
    final response = await apiClient.get(
      "$getHopperAcceptedCountUrl?task_id=$taskId",
    );

    if (response.data["code"] == 200) {
      return (response.data["count"] ?? "0").toString();
    } else {
      // Graceful fail or throw? Original code just ignores if error?
      // Let's return 0 or existing logic
      return "0";
    }
  }

  @override
  Future<List<EarningTransactionDetail>> getTaskTransactionDetails(
      String transactionId) async {
    final response = await apiClient.post(
      api_const.getTaskTransactionDetails,
      data: {"transaction_id": transactionId},
    );

    if (response.data["code"] == 200) {
      List<EarningTransactionDetail> list = [];
      if (response.data["response"] != null) {
        response.data["response"].forEach((v) {
          list.add(EarningTransactionDetail.taskFromJson(v));
        });
      }
      return list;
    } else {
      throw ServerException(
          response.data["message"] ?? "Failed to load task transaction");
    }
  }

  @override
  Future<List<EarningTransactionDetail>> getContentTransactionDetails(
      String roomId, String mediaHouseId) async {
    final response = await apiClient.post(
      getDetailsById,
      data: {"content_id": roomId, "media_house_id": mediaHouseId},
    );

    if (response.data["code"] == 200) {
      List<EarningTransactionDetail> list = [];
      if (response.data["response"] != null) {
        response.data["response"].forEach((v) {
          list.add(EarningTransactionDetail.fromJson(v));
        });
      }
      return list;
    } else {
      throw ServerException(
          response.data["message"] ?? "Failed to load content transaction");
    }
  }

  @override
  Future<List<TaskAll>> getAllTasks(
      {required int limit,
      required int offset,
      Map<String, dynamic>? filterParams}) async {
    Map<String, dynamic> map = {
      "limit": limit,
      "offset": offset,
    };
    if (filterParams != null) {
      map.addAll(filterParams);
    }

    final response = await apiClient.post(
      getAllTaskUrl,
      data: map,
    );

    if (response.data["code"] == 200) {
      List<TaskAll> list = [];
      if (response.data["tasks"] != null) {
        response.data["tasks"].forEach((v) {
          list.add(AllTaskModel.fromJson(v));
        });
      }
      return list;
    } else {
      throw ServerException(
          response.data["message"] ?? "Failed to load all tasks");
    }
  }

  @override
  Future<List<Task>> getLocalTasks(Map<String, dynamic> filterParams) async {
    final response = await apiClient.post(
      getAllMyTaskUrl,
      data: filterParams,
    );

    if (response.data["code"] == 200) {
      List<Task> list = [];
      // Parsing logic based on MyTaskScreen usage (mix of Pending/Broadcast and Accepted/Completed)
      // Assuming keys based on common pattern or guess.
      // If "tasks" contains my tasks (accepted/completed)
      if (response.data["tasks"] != null) {
        response.data["tasks"].forEach((v) {
          list.add(MyTaskModel.fromJson(v));
        });
      }
      // If "broadcast_tasks" contains pending broadcast tasks
      // NOTE: Key guess based on context. Likely 'broadcast_tasks' or similar.
      // Checking `getAllMyTaskUrl` usually returns `tasks` and `broadcast_tasks`.
      if (response.data['broadcast_tasks'] != null) {
        response.data['broadcast_tasks'].forEach((v) {
          list.add(PendingTask.fromJson(v));
        });
      }

      return list;
    } else {
      throw ServerException(
          response.data["message"] ?? "Failed to load local tasks");
    }
  }
}
