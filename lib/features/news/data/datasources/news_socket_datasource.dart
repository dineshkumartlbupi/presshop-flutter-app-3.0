import 'package:flutter/foundation.dart';
import 'package:presshop/core/api/global_socket_client.dart';
import 'package:presshop/core/api/socket_constants.dart';

class NewsSocketDataSource {
  final GlobalSocketClient _client;

  NewsSocketDataSource({required GlobalSocketClient client}) : _client = client;

  Function(dynamic)? onCommentNew;
  Function(dynamic)? onCommentLike;
  Function(dynamic)? onNewsShare;
  Function(dynamic)? onNewsLike;

  bool get isInitialized => _client.isInitialized;

  void initSocket({required String userId, required String userType}) {
    _client.initSocket(userId: userId, userType: userType);
  }

  void initializeListeners() {
    _client.on(SocketEvents.aggregatedCommentLike, (like) {
      debugPrint(
          "NewsSocketDataSource: aggregated:comment:like received: $like");
      onCommentLike?.call(like);
    });

    _client.on(SocketEvents.aggregatedNewsLike, (like) {
      debugPrint("NewsSocketDataSource: aggregated:news:like received: $like");
      onNewsLike?.call(like);
    });

    _client.on(SocketEvents.aggregatedCommentNew, (comment) {
      debugPrint(
          "NewsSocketDataSource: aggregated:comment:new received: $comment");
      onCommentNew?.call(comment);
    });

    _client.on(SocketEvents.aggregatedNewsShare, (share) {
      debugPrint(
          "NewsSocketDataSource: aggregated:news:share received: $share");
      onNewsShare?.call(share);
    });
  }

  void joinNewsAll() {
    debugPrint("NewsSocketDataSource: Joining news:all room");
    _client.emit(SocketEvents.joinNewsAll);
  }

  void joinContent(String contentId) {
    debugPrint("NewsSocketDataSource: Joining content room: $contentId");
    _client.emit(SocketEvents.joinContent, contentId);
  }

  void addComment({
    required String contentId,
    required String text,
    required String userId,
    String? parentId,
    String? rootParentId,
    String? replyToName,
  }) {
    final data = {
      'id': contentId,
      'text': text,
      'parent_id': parentId,
      'root_parent_id': rootParentId,
      'user_id': userId,
      'reply_to_user_name': replyToName != null ? '@$replyToName' : null,
    };
    debugPrint("NewsSocketDataSource: Emitting add:aggregated:comment: $data");
    _client.emit(SocketEvents.addAggregatedComment, data);
  }

  void likeComment({
    required String contentId,
    required String commentId,
    required String userId,
  }) {
    final data = {
      "contentId": contentId,
      "commentId": commentId,
      "userId": userId,
    };
    debugPrint(
        "NewsSocketDataSource: Emitting add:aggregated:comment:like: $data");
    _client.emit(SocketEvents.addAggregatedCommentLike, data);
  }

  void likeNews({required String userId, required String contentId}) {
    final data = {"user_id": userId, "contentId": contentId};
    debugPrint(
        "NewsSocketDataSource: Emitting add:aggregated:news:like: $data");
    _client.emit(SocketEvents.addAggregatedNewsLike, data);
  }

  void viewNews({required String contentId}) {
    final data = {"contentId": contentId};
    debugPrint(
        "NewsSocketDataSource: Emitting add:aggregated:news:view: $data");
    _client.emit(SocketEvents.addAggregatedNewsView, data);
  }

  void shareNews({required String contentId, String? userId}) {
    final data = {
      "contentId": contentId,
      if (userId != null) "user_id": userId,
    };
    debugPrint(
        "NewsSocketDataSource: Emitting add:aggregated:news:share: $data");
    _client.emit(SocketEvents.addAggregatedNewsShare, data);
  }

  void dispose() {
    _client.off(SocketEvents.aggregatedCommentLike);
    _client.off(SocketEvents.aggregatedNewsLike);
    _client.off(SocketEvents.aggregatedCommentNew);
    _client.off(SocketEvents.aggregatedNewsShare);
  }
}
