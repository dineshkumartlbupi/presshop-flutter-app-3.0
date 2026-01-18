import 'package:equatable/equatable.dart';
import 'package:presshop/features/news/domain/entities/comment.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

class GetAggregatedNewsEvent extends NewsEvent {
  final double lat;
  final double lng;
  final double km;
  final String category;
  final String? alertType;
  final int limit;
  final int offset;

  const GetAggregatedNewsEvent({
    required this.lat,
    required this.lng,
    required this.km,
    this.category = "all",
    this.alertType,
    this.limit = 10,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [lat, lng, km, category, alertType, limit, offset];
}

class GetNewsDetailEvent extends NewsEvent {
  final String id;

  const GetNewsDetailEvent({required this.id});

  @override
  List<Object> get props => [id];
}

class GetCommentsEvent extends NewsEvent {
  final String contentId;
  final int limit;

  const GetCommentsEvent({required this.contentId, this.limit = 15});

  @override
  List<Object> get props => [contentId, limit];
}

class AddCommentLocalEvent extends NewsEvent {
  final Comment comment;
  final String? parentId;

  const AddCommentLocalEvent({required this.comment, this.parentId});

  @override
  List<Object?> get props => [comment, parentId];
}

class UpdateLikeLocalEvent extends NewsEvent {
  final String commentId;
  final int count;

  const UpdateLikeLocalEvent({required this.commentId, required this.count});

  @override
  List<Object> get props => [commentId, count];
}

class ToggleLikeStatusEvent extends NewsEvent {
  final String commentId;
  final bool isLiked;

  const ToggleLikeStatusEvent({required this.commentId, required this.isLiked});

  @override
  List<Object> get props => [commentId, isLiked];
}

class IncrementViewCountEvent extends NewsEvent {
  @override
  List<Object> get props => [];
}

class ToggleNewsLikeEvent extends NewsEvent {
  final String contentId;
  const ToggleNewsLikeEvent({required this.contentId});
  @override
  List<Object> get props => [contentId];
}

class OnNewsLikeUpdatedEvent extends NewsEvent {
  final dynamic likeData;
  const OnNewsLikeUpdatedEvent({required this.likeData});
  @override
  List<Object> get props => [likeData];
}

class UpdateShareCountEvent extends NewsEvent {
  final int count;

  const UpdateShareCountEvent({required this.count});

  @override
  List<Object> get props => [count];
}
