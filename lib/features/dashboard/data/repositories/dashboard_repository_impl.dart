import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/api/network_info.dart';
import '../../domain/entities/admin_detail.dart';
import '../../domain/entities/student_beans_info.dart';
import 'package:presshop/features/task/domain/entities/task_detail.dart';
import 'package:presshop/features/notification/domain/entities/notification_entity.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<AdminDetail>>> getActiveAdmins() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteActiveAdmins = await remoteDataSource.getActiveAdmins();
        return Right(remoteActiveAdmins);
      } on ServerFailure {
        return Left(ServerFailure(message: ''));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateLocation(
      Map<String, dynamic> params) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateLocation(params);
        return const Right(null);
      } on ServerFailure {
        return Left(ServerFailure(message: ''));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addDevice(Map<String, dynamic> params) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.addDevice(params);
        return const Right(null);
      } on ServerFailure {
        return Left(ServerFailure(message: ''));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, TaskDetail>> getTaskDetail(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final taskDetail = await remoteDataSource.getTaskDetail(id);
        return Right(taskDetail);
      } on ServerFailure {
        return Left(ServerFailure(message: ''));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRoomId(
      Map<String, dynamic> params) async {
    if (await networkInfo.isConnected) {
      try {
        final roomIdData = await remoteDataSource.getRoomId(params);
        return Right(roomIdData);
      } on ServerFailure {
        return Left(ServerFailure(message: ''));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> checkAppVersion() async {
    if (await networkInfo.isConnected) {
      try {
        final versionData = await remoteDataSource.checkAppVersion();
        return Right(versionData);
      } on ServerFailure catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> activateStudentBeans() async {
    if (await networkInfo.isConnected) {
      try {
        final data = await remoteDataSource.activateStudentBeans();
        return Right(data);
      } catch (e) {
        return Left(ApiErrorHandler.handle(e));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, StudentBeansInfo>> checkStudentBeans() async {
    if (await networkInfo.isConnected) {
      try {
        final map = await remoteDataSource.checkStudentBeans();

        if (map["code"] == 200) {
          final src1 = map["userData"]?["source"];
          if (src1 != null) {
            final sourceDataIsOpened = src1["is_opened"] ?? false;
            final sourceDataType = src1["type"] ?? "";
            final sourceDataHeading = src1["heading"] ?? "";
            final sourceDataDescription = src1["description"] ?? "";
            final isClick = src1["is_clicked"] ?? false;

            if ((sourceDataType.toString().toLowerCase() == 'studentbeans') &&
                sourceDataIsOpened == false &&
                isClick == false) {
              return Right(StudentBeansInfo(
                shouldShow: true,
                heading: sourceDataHeading,
                description: sourceDataDescription,
              ));
            }
          }
        }
        return const Right(StudentBeansInfo(shouldShow: false));
      } catch (e) {
        return Left(ApiErrorHandler.handle(e));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markStudentBeansVisited() async {
    try {
      await remoteDataSource.markStudentBeansVisited();
      return const Right(null);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeDevice(
      Map<String, dynamic> params) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.removeDevice(params);
        return const Right(null);
      } on ServerFailure {
        return Left(ServerFailure(message: ''));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
