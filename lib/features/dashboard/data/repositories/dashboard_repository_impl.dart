import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/api/network_info.dart';
import '../../domain/entities/admin_detail.dart';
import '../../domain/entities/task_detail.dart';
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
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateLocation(Map<String, dynamic> params) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateLocation(params);
        return const Right(null);
      } on ServerFailure {
        return Left(ServerFailure());
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
        return Left(ServerFailure());
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
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRoomId() async {
    if (await networkInfo.isConnected) {
      try {
        final roomIdData = await remoteDataSource.getRoomId();
        return Right(roomIdData);
      } on ServerFailure {
        return Left(ServerFailure());
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
      } on ServerFailure {
        return Left(ServerFailure());
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
      } on ServerFailure {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> removeDevice(Map<String, dynamic> params) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.removeDevice(params);
        return const Right(null);
      } on ServerFailure {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
