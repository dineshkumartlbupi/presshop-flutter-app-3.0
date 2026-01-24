import 'package:dio/dio.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:presshop/core/api/api_constant_new.dart';
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
    try {
      final response = await apiClient.get(
        "${ApiConstantsNew.tasks.assignedTaskDetail}$taskId",
      );

      final data = response.data;
      var responseData = data;

      // Handle nested structure: data['data']
      if (data['data'] != null && data['data'] is Map) {
        responseData = data['data'];
      }

      if (responseData["code"] == 200) {
        String roomId = "";
        if (responseData["resp"] != null) {
          roomId = (responseData["resp"]["room_id"] ?? "").toString();
        }
        return TaskDetailModel.fromJson(responseData["task"] ?? {},
            roomId: roomId);
      } else {
        throw ServerException(
            responseData["message"] ?? "Failed to load task details");
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<void> acceptRejectTask(
      {required String taskId,
      required String mediaHouseId,
      required String status}) async {
    try {
      final response = await apiClient
          .post(ApiConstantsNew.tasks.acceptRejectTask, data: {
        "task_id": taskId,
        "media_house_id": mediaHouseId,
        "task_status": status
      });

      if (response.statusCode != 200) {
        throw ServerException(
            response.data["message"] ?? "Failed to accept/reject task");
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<ManageTaskChatModel>> getTaskChat(
      String roomId, String type, String contentId) async {
    try {
      final response = await apiClient.post(
        ApiConstantsNew.chat.getOfferPaymentChat,
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
        throw ServerException(
            response.data["message"] ?? "Failed to load chats");
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<Map<String, dynamic>> uploadTaskMedia(FormData data) async {
    try {
      final response = await apiClient.multipartPost(
        ApiConstantsNew.tasks.uploadTaskMedia,
        formData: data,
      );
      if (response.data["success"] == true) {
        return response.data;
      } else {
        throw ServerException(
            response.data["message"] ?? "Failed to upload media");
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<String> getRoomId(
      String receiverId, String taskId, String roomType, String type) async {
    try {
      Map<String, String> map = {
        "receiver_id": receiverId,
        "room_type": roomType, // "HoppertoAdmin"
        "type": type, // "external_task"
        "task_id": taskId,
      };

      final response = await apiClient.post(
        ApiConstantsNew.chat.createRoom,
        data: map,
      );

      if (response.data["code"] == 200 && response.data["resp"] != null) {
        return (response.data["resp"]["room_id"] ?? "").toString();
      } else {
        throw ServerException(
            response.data["message"] ?? "Failed to get room ID");
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<String> getHopperAcceptedCount(String taskId) async {
    try {
      final response = await apiClient.get(
        "${ApiConstantsNew.tasks.acceptedHopperCount}?task_id=$taskId",
      );

      if (response.data["code"] == 200) {
        return (response.data["count"] ?? "0").toString();
      } else {
        // Graceful fail or throw? Original code just ignores if error?
        // Let's return 0 or existing logic
        return "0";
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<EarningTransactionDetail>> getTaskTransactionDetails(
      String transactionId) async {
    try {
      final response = await apiClient.post(
        ApiConstantsNew.tasks.transactionDetails,
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
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<EarningTransactionDetail>> getContentTransactionDetails(
      String roomId, String mediaHouseId) async {
    try {
      final response = await apiClient.post(
        ApiConstantsNew.misc.getDetailsById,
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
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<TaskAll>> getAllTasks(
      {required int limit,
      required int offset,
      Map<String, dynamic>? filterParams}) async {
    try {
      Map<String, dynamic> map = {
        "limit": limit,
        "offset": offset,
      };
      if (filterParams != null) {
        map.addAll(filterParams);
      }

      final response = await apiClient.post(
        ApiConstantsNew.tasks.allTasks,
        data: map,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        List<TaskAll> list = [];

        List? targetList;

        if (data["tasks"] != null) {
          targetList = data["tasks"];
        } else if (data["data"] is List) {
          targetList = data["data"];
        } else if (data["data"] is Map && data["data"]["data"] is List) {
          targetList = data["data"]["data"];
        }

        if (targetList != null) {
          for (var v in targetList) {
            list.add(AllTaskModel.fromJson(v));
          }
        }
        return list;
      } else {
        throw ServerException(
            response.data["message"] ?? "Failed to load all tasks");
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<Task>> getLocalTasks(Map<String, dynamic> filterParams) async {
    try {
      final response = await apiClient.post(
        ApiConstantsNew.tasks.myTasks,
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
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
