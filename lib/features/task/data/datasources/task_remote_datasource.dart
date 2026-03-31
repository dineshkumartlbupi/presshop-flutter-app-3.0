import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/core/common_models_export.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';
import 'package:presshop/core/error/exceptions.dart';
import 'package:presshop/features/task/data/models/all_task_model.dart';
import 'package:presshop/features/task/data/models/my_task_model.dart';
import 'package:presshop/features/task/domain/entities/task.dart';
import 'package:presshop/features/task/domain/entities/task_all.dart';
import 'dart:convert';
import 'package:presshop/features/task/data/models/task_assigned_response_model.dart';

abstract class TaskRemoteDataSource {
  Future<TaskAssignedResponseModel> getTaskDetail(String taskId,
      {double? latitude, double? longitude, bool showLoader = true});
  Future<void> acceptRejectTask(
      {required String taskId,
      required String mediaHouseId,
      required String status});
  Future<List<ManageTaskChatModel>> getTaskChat(
      String roomId, String type, String contentId,
      {bool showLoader = true});
  Future<Map<String, dynamic>> uploadTaskMedia(FormData data,
      {bool showLoader = true});
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
      Map<String, dynamic>? filterParams,
      bool showLoader = true});
  Future<List<Task>> getLocalTasks(Map<String, dynamic> filterParams,
      {bool showLoader = true});
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final ApiClient apiClient;

  TaskRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<TaskAssignedResponseModel> getTaskDetail(String taskId,
      {double? latitude, double? longitude, bool showLoader = true}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;

      final response = await apiClient.get(
          "${ApiConstantsNew.tasks.assignedTaskDetail}$taskId",
          queryParameters: queryParams.isNotEmpty ? queryParams : null,
          showLoader: showLoader);

      final data = response.data;
      var responseData = data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (e) {
          debugPrint("Failed to decode response string: $e");
        }
      }

      // Handle nested structure: data['data']
      if (responseData != null) {
        if (responseData is Map && responseData.containsKey('data')) {
          debugPrint("✅ Data before inner parsing: $responseData");
          var innerData = responseData['data'];
          // Check if inner data is string
          if (innerData is String) {
            try {
              innerData = jsonDecode(innerData);
              responseData['data'] = innerData;
            } catch (e) {
              debugPrint("Failed to decode inner data string: $e");
            }
          }

          // Check nested 'task' field
          if (innerData is Map && innerData.containsKey('task')) {
            var taskData = innerData['task'];
            if (taskData is String) {
              try {
                innerData['task'] = jsonDecode(taskData);
              } catch (e) {
                debugPrint("Failed to decode nested task string: $e");
              }
            }
          }

          // Check nested 'resp' field logic
          if (innerData is Map) {
            // Handle "response" key vs "resp" key mismatch
            if (innerData.containsKey('response') &&
                !innerData.containsKey('resp')) {
              innerData['resp'] = innerData['response'];
            }

            if (innerData.containsKey('resp')) {
              var respData = innerData['resp'];
              if (respData is String) {
                try {
                  innerData['resp'] = jsonDecode(respData);
                } catch (e) {
                  debugPrint("Failed to decode nested resp string: $e");
                }
              }
            }
          }
        }
      }

      if (response.statusCode == 200) {
        debugPrint("✅ Final Response Data passed to fromJson: $responseData");
        return TaskAssignedResponseModel.fromJson(responseData);
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

      final rawData = response.data;
      final bool isSuccess = rawData["success"] == true ||
          rawData["code"] == 200 ||
          (rawData["status"]?.toString().toLowerCase() == "success");

      if (isSuccess ||
          response.statusCode == 200 ||
          response.statusCode == 201) {
        return;
      } else {
        throw ServerException(
            rawData["message"] ?? "Failed to accept/reject task");
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  dynamic extractApiData(dynamic rawData) {
    if (rawData == null) return null;

    // Step 1: detect main container
    dynamic container = rawData["data"] ??
        rawData["response"] ??
        rawData["resposne"] ??
        rawData;

    // Step 2: if list directly
    if (container is List) {
      return container;
    }

    // Step 3: if map
    if (container is Map) {
      // handle chat structure
      if (container["chat"] is List) {
        List flattened = [];

        for (var group in container["chat"]) {
          if (group["publication"] is List) {
            flattened.addAll(group["publication"]);
          } else {
            flattened.add(group);
          }
        }

        return flattened;
      }

      // normal object response (like version API)
      return container;
    }

    return null;
  }

  @override
  Future<List<ManageTaskChatModel>> getTaskChat(
      String roomId, String type, String contentId,
      {bool showLoader = true}) async {
    try {
      debugPrint(
          "🚀 getTaskChat: type='$type', contentId='$contentId', roomId='$roomId'");

      final bool isTaskContent = type == "task_content";

      final String url = isTaskContent
          ? ApiConstantsNew.chat.chatList
          : ApiConstantsNew.chat.getOfferPaymentChat;

      final Map<String, dynamic> body = isTaskContent
          ? {"room_id": roomId, "type": "task_content"}
          : {"content_id": contentId};

      final response =
          await apiClient.post(url, data: body, showLoader: showLoader);

      debugPrint("🚀 getTaskChat Response Status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final rawData = response.data;
        List<ManageTaskChatModel> chatList = [];

        dynamic possibleList;

        /// Step 1: detect main container
        final container = rawData["data"] ??
            rawData["response"] ??
            rawData["resposne"] ??
            rawData;

        /// Step 2: if container is list
        if (container is List) {
          possibleList = container;
        }

        /// Step 3: if container is map
        else if (container is Map) {
          if (container["chat"] is List) {
            final List groupedList = container["chat"];
            List flattened = [];

            for (var group in groupedList) {
              if (group["publication"] is List) {
                flattened.addAll(group["publication"]);
              } else {
                flattened.add(group);
              }
            }

            possibleList = flattened;
          }
        }

        /// Step 4: map to model
        if (possibleList is List) {
          debugPrint(
              "🚀 getTaskChat Found List Length: ${possibleList.length}");

          for (var v in possibleList) {
            if (v["message_type"] == "initialoffer" ||
                v["message_type"] == "Mediahouse_initial_offer") {
              v["message_type"] = "Offered";
            }

            chatList.add(ManageTaskChatModel.fromJson(v));
          }
        }

        return chatList;
      } else {
        throw ServerException(
            response.data["message"] ?? "Failed to load chat");
      }
    } catch (e) {
      debugPrint("🚀 getTaskChat Exception: $e");
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<Map<String, dynamic>> uploadTaskMedia(FormData data,
      {bool showLoader = true}) async {
    try {
      final response = await apiClient.multipartPost(
        ApiConstantsNew.tasks.uploadTaskMedia,
        formData: data,
        showLoader: showLoader,
      );

      final rawData = response.data;
      final bool isSuccess = rawData["success"] == true ||
          rawData["code"] == 200 ||
          (rawData["status"]?.toString().toLowerCase() == "success");

      if (isSuccess ||
          response.statusCode == 200 ||
          response.statusCode == 201) {
        return rawData;
      } else {
        throw ServerException(rawData["message"] ?? "Failed to upload media");
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

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          (response.data["details"] != null || response.data["resp"] != null)) {
        final data = response.data["details"] ?? response.data["resp"];
        return (data["room_id"] ?? "").toString();
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
      Map<String, dynamic>? filterParams,
      bool showLoader = true}) async {
    try {
      Map<String, dynamic> queryParams = {
        "limit": limit,
        "offset": offset,
      };
      if (filterParams != null) {
        queryParams.addAll(filterParams);
      }

      // Changed to GET as per Mobile Integration Guide
      // URL: /api/hopper/tasks/assigned/by/mediaHouse
      // Query Params: latitude, longitude
      final response = await apiClient.get(
        ApiConstantsNew.tasks.allTasks, // Base URL for assigned tasks
        queryParameters: queryParams,
        showLoader: showLoader,
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
  Future<List<Task>> getLocalTasks(Map<String, dynamic> filterParams,
      {bool showLoader = true}) async {
    try {
      final response = await apiClient.get(
        ApiConstantsNew.tasks.myTasks,
        queryParameters: filterParams,
        showLoader: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<Task> list = [];
        Set<String> seenIds = {};

        final body = response.data;

        if (body != null && body["data"] is List) {
          for (var v in body["data"]) {
            final task = MyTaskModel.fromJson(v);

            if (task.taskDetail != null &&
                !seenIds.contains(task.taskDetail!.id)) {
              list.add(task);
              seenIds.add(task.taskDetail!.id);
            }
          }
        }

        if (body != null && body["pending_unaccepted"] is List) {
          for (var v in body["pending_unaccepted"]) {
            final task = PendingTask.fromJson(v);

            if (task.taskDetail != null &&
                !seenIds.contains(task.taskDetail!.id)) {
              list.add(task);
              seenIds.add(task.taskDetail!.id);
            }
          }
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
