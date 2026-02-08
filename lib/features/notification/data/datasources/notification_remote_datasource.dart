import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import '../../../../core/api/api_constant.dart';

abstract class NotificationRemoteDataSource {
  Future<Map<String, dynamic>> getNotifications(int limit, int offset);
  Future<void> markNotificationsAsRead();
  Future<void> clearAllNotifications();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<Map<String, dynamic>> getNotifications(int limit, int offset) async {
    try {
      final response = await apiClient.get(
        ApiConstantsNew.chat.notificationList,
        queryParameters: {'limit': limit, 'offset': offset},
        showLoader: false,
      );
      return response.data;
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<void> markNotificationsAsRead() async {
    try {
      await apiClient.patch(ApiConstantsNew.chat.notificationRead);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<void> clearAllNotifications() async {
    try {
      await apiClient.patch(ApiConstantsNew.chat.clearNotification);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
