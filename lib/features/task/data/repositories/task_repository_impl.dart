import 'package:dartz/dartz.dart' hide Task;
import 'package:dio/dio.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/error/exceptions.dart';
import 'package:presshop/features/task/domain/repositories/task_repository.dart';
import 'package:presshop/features/task/data/datasources/task_remote_datasource.dart';
import 'package:presshop/core/common_models_export.dart';

import 'package:presshop/features/earning/data/models/earning_model.dart';
import 'package:presshop/core/api/network_info.dart';
import 'package:presshop/features/task/domain/entities/task.dart';
import 'package:presshop/features/task/domain/entities/task_all.dart';
import 'package:presshop/features/task/domain/entities/task_assigned_entity.dart';
import 'package:presshop/features/task/domain/mappers/task_assigned_mapper.dart';

class TaskRepositoryImpl implements TaskRepository {

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  final TaskRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, TaskAssignedEntity>> getTaskDetail(String taskId,
      {bool showLoader = true}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTask = await remoteDataSource.getTaskDetail(taskId,
            showLoader: showLoader);
        return Right(remoteTask.data.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> acceptRejectTask(
      {required String taskId,
      required String mediaHouseId,
      required String status}) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.acceptRejectTask(
            taskId: taskId, mediaHouseId: mediaHouseId, status: status);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<ManageTaskChatModel>>> getTaskChat(
      String roomId, String type, String contentId,
      {bool showLoader = true}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteChat = await remoteDataSource
            .getTaskChat(roomId, type, contentId, showLoader: showLoader);
        return Right(remoteChat);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> uploadTaskMedia(FormData data,
      {bool showLoader = true}) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.uploadTaskMedia(data,
            showLoader: showLoader);
        return Right(response);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> getRoomId(
      String receiverId, String taskId, String roomType, String type) async {
    if (await networkInfo.isConnected) {
      try {
        final roomId = await remoteDataSource.getRoomId(
            receiverId, taskId, roomType, type);
        return Right(roomId);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> getHopperAcceptedCount(String taskId) async {
    if (await networkInfo.isConnected) {
      try {
        final count = await remoteDataSource.getHopperAcceptedCount(taskId);
        return Right(count);
      } on ServerException catch (e) {
        // Warning: Original code doesn't explicitly handle errors for this call deeply.
        // Returning default "0" or error? Left for now.
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<EarningTransactionDetail>>>
      getTaskTransactionDetails(String transactionId) async {
    if (await networkInfo.isConnected) {
      try {
        final result =
            await remoteDataSource.getTaskTransactionDetails(transactionId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<EarningTransactionDetail>>>
      getContentTransactionDetails(String roomId, String mediaHouseId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getContentTransactionDetails(
            roomId, mediaHouseId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<TaskAll>>> getAllTasks(
      {required int limit,
      required int offset,
      Map<String, dynamic>? filterParams,
      bool showLoader = true}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getAllTasks(
            limit: limit,
            offset: offset,
            filterParams: filterParams,
            showLoader: showLoader);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getLocalTasks(
      Map<String, dynamic> filterParams,
      {bool showLoader = true}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getLocalTasks(filterParams,
            showLoader: showLoader);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
