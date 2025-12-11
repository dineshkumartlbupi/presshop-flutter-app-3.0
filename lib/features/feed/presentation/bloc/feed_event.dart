import 'package:equatable/equatable.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class FetchFeeds extends FeedEvent {
  final bool isRefresh;
  final Map<String, dynamic>? newFilters;

  const FetchFeeds({this.isRefresh = false, this.newFilters});

  @override
  List<Object?> get props => [isRefresh, newFilters];
}

class ToggleLikeFeed extends FeedEvent {
  final String id;
  final bool isLiked;
  const ToggleLikeFeed({required this.id, required this.isLiked});
  @override
  List<Object?> get props => [id, isLiked];
}

class ToggleFavouriteFeed extends FeedEvent {
  final String id;
  final bool isFavourite;
  const ToggleFavouriteFeed({required this.id, required this.isFavourite});
  @override
  List<Object?> get props => [id, isFavourite];
}

class ToggleEmojiFeed extends FeedEvent {
  final String id;
  final bool isEmoji;
  const ToggleEmojiFeed({required this.id, required this.isEmoji});
  @override
  List<Object?> get props => [id, isEmoji];
}

class ToggleClapFeed extends FeedEvent {
  final String id;
  final bool isClap;
  const ToggleClapFeed({required this.id, required this.isClap});
  @override
  List<Object?> get props => [id, isClap];
}

class LoadMoreFeeds extends FeedEvent {}
