import 'package:dartz/dartz.dart' hide Task;
import 'package:dio/dio.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/task/domain/entities/task_assigned_entity.dart';
import 'package:presshop/features/task/domain/entities/task.dart';
import 'package:presshop/features/task/domain/entities/task_all.dart';
import 'package:presshop/core/common_models_export.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';

import 'package:presshop/features/task/domain/entities/manage_task_chat_response.dart';

abstract class TaskRepository {
  Future<Either<Failure, TaskAssignedEntity>> getTaskDetail(String taskId,
      {double? latitude, double? longitude, bool showLoader = true});
  Future<Either<Failure, void>> acceptRejectTask(
      {required String taskId,
      required String mediaHouseId,
      required String status});
  Future<Either<Failure, ManageTaskChatResponse>> getTaskChat(
      String roomId, String type, String contentId,
      {bool showLoader = true});
  Future<Either<Failure, Map<String, dynamic>>> uploadTaskMedia(FormData data,
      {bool showLoader = true});
  Future<Either<Failure, String>> getRoomId(
      String receiverId, String taskId, String roomType, String type);
  Future<Either<Failure, String>> getHopperAcceptedCount(String taskId);
  Future<Either<Failure, List<EarningTransactionDetail>>>
      getTaskTransactionDetails(String transactionId);
  Future<Either<Failure, List<EarningTransactionDetail>>>
      getContentTransactionDetails(String roomId, String mediaHouseId);
  Future<Either<Failure, List<TaskAll>>> getAllTasks(
      {required int limit,
      required int offset,
      Map<String, dynamic>? filterParams,
      bool showLoader = true});
  Future<Either<Failure, List<Task>>> getLocalTasks(
      Map<String, dynamic> filterParams,
      {bool showLoader = true});
}
