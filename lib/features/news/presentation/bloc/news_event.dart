import 'package:equatable/equatable.dart';
import 'package:presshop/features/news/domain/entities/comment.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

class GetAggregatedNewsEvent extends NewsEvent {
  const GetAggregatedNewsEvent({
    required this.lat,
    required this.lng,
    required this.km,
    this.category = "all",
    this.alertType,
    this.limit = 10,
    this.offset = 0,
    this.prioritizedContentId,
  });
  final double lat;
  final double lng;
  final double km;
  final String category;
  final String? alertType;
  final int limit;
  final int offset;
  final String? prioritizedContentId;

  @override
  List<Object?> get props =>
      [lat, lng, km, category, alertType, limit, offset, prioritizedContentId];
}

class GetAllNewsEvent extends NewsEvent {
  const GetAllNewsEvent({
    this.km = 3.21869, // Default to 2 miles
    this.category = "all",
    this.alertType,
    this.limit = 10,
    this.offset = 0,
  });
  final double km;
  final String category;
  final String? alertType;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [km, category, alertType, limit, offset];
}

class GetNewsDetailEvent extends NewsEvent {
  const GetNewsDetailEvent({required this.id});
  final String id;

  @override
  List<Object> get props => [id];
}

class GetCommentsEvent extends NewsEvent {
  const GetCommentsEvent(
      {required this.contentId, this.limit = 15, this.offset = 0});
  final String contentId;
  final int limit;
  final int offset;

  @override
  List<Object> get props => [contentId, limit, offset];
}

class AddCommentLocalEvent extends NewsEvent {
  const AddCommentLocalEvent({required this.comment, this.parentId});
  final Comment comment;
  final String? parentId;

  @override
  List<Object?> get props => [comment, parentId];
}

class UpdateLikeLocalEvent extends NewsEvent {
  const UpdateLikeLocalEvent({required this.commentId, required this.count});
  final String commentId;
  final int count;

  @override
  List<Object> get props => [commentId, count];
}

class ToggleLikeStatusEvent extends NewsEvent {
  const ToggleLikeStatusEvent({required this.commentId, required this.isLiked});
  final String commentId;
  final bool isLiked;

  @override
  List<Object> get props => [commentId, isLiked];
}

class IncrementViewCountEvent extends NewsEvent {
  @override
  List<Object> get props => [];
}

class ToggleNewsLikeEvent extends NewsEvent {
  const ToggleNewsLikeEvent({required this.contentId});
  final String contentId;
  @override
  List<Object> get props => [contentId];
}

class OnNewsLikeUpdatedEvent extends NewsEvent {
  const OnNewsLikeUpdatedEvent({required this.likeData});
  final dynamic likeData;
  @override
  List<Object> get props => [likeData];
}

class UpdateShareCountEvent extends NewsEvent {
  const UpdateShareCountEvent({required this.count});
  final int count;

  @override
  List<Object> get props => [count];
}

class ToggleCommentLikeEvent extends NewsEvent {
  const ToggleCommentLikeEvent(
      {required this.contentId, required this.commentId});
  final String contentId;
  final String commentId;
  @override
  List<Object> get props => [contentId, commentId];
}

class PostCommentEvent extends NewsEvent {
  const PostCommentEvent({
    required this.contentId,
    required this.text,
    this.parentId,
    this.rootParentId,
    this.replyToName,
  });
  final String contentId;
  final String text;
  final String? parentId;
  final String? rootParentId;
  final String? replyToName;

  @override
  List<Object?> get props =>
      [contentId, text, parentId, rootParentId, replyToName];
}

class ShareNewsEvent extends NewsEvent {
  const ShareNewsEvent({required this.contentId});
  final String contentId;

  @override
  List<Object> get props => [contentId];
}

class ViewNewsEvent extends NewsEvent {
  const ViewNewsEvent({required this.contentId});
  final String contentId;

  @override
  List<Object> get props => [contentId];
}

class OnCommentNewEvent extends NewsEvent {
  const OnCommentNewEvent({required this.commentData});
  final dynamic commentData;

  @override
  List<Object> get props => [commentData];
}

class OnNewsShareUpdatedEvent extends NewsEvent {
  const OnNewsShareUpdatedEvent({required this.shareData});
  final dynamic shareData;

  @override
  List<Object> get props => [shareData];
}

class OnCommentLikeUpdatedEvent extends NewsEvent {
  const OnCommentLikeUpdatedEvent({required this.likeData});
  final dynamic likeData;

  @override
  List<Object> get props => [likeData];
}
