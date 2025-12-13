import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, NotificationsResult>> getNotifications(int limit, int offset) async {
    try {
      final remoteData = await remoteDataSource.getNotifications(limit, offset);
      
      List<NotificationModel> notifications = [];
      if (remoteData['data'] != null) {
        notifications = (remoteData['data'] as List)
            .map((e) => NotificationModel.fromJson(e))
            .toList();
      }
      
      int unreadCount = remoteData['unreadCount'] ?? 0;
      int alertCount = remoteData['hopperAlertCount'] ?? 0;
      
      return Right(NotificationsResult(
        notifications: notifications,
        unreadCount: unreadCount,
        alertCount: alertCount,
      ));
    } catch (e) {
      return Left(ServerFailure(message:  e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markNotificationsAsRead() async {
    try {
      await remoteDataSource.markNotificationsAsRead();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message:  e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllNotifications() async {
    try {
      await remoteDataSource.clearAllNotifications();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message:  e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudentBeansInfo>> checkStudentBeans() async {
    try {
      final map = await remoteDataSource.checkStudentBeans();
      
      if (map["code"] == 200) {
        final src1 = map["userData"]["source"];
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
      return Left(ServerFailure(message:  e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> activateStudentBeans() async {
    try {
      final url = await remoteDataSource.activateStudentBeans();
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(message:  e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markStudentBeansVisited() async {
    try {
      await remoteDataSource.markStudentBeansVisited();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message:  e.toString()));
    }
  }
}
