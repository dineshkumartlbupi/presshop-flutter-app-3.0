import 'package:equatable/equatable.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class FetchFeeds extends FeedEvent {

  const FetchFeeds({this.isRefresh = false, this.newFilters});
  final bool isRefresh;
  final Map<String, dynamic>? newFilters;

  @override
  List<Object?> get props => [isRefresh, newFilters];
}

class ToggleLikeFeed extends FeedEvent {
  const ToggleLikeFeed({required this.id, required this.isLiked});
  final String id;
  final bool isLiked;
  @override
  List<Object?> get props => [id, isLiked];
}

class ToggleFavouriteFeed extends FeedEvent {
  const ToggleFavouriteFeed({required this.id, required this.isFavourite});
  final String id;
  final bool isFavourite;
  @override
  List<Object?> get props => [id, isFavourite];
}

class ToggleEmojiFeed extends FeedEvent {
  const ToggleEmojiFeed({required this.id, required this.isEmoji});
  final String id;
  final bool isEmoji;
  @override
  List<Object?> get props => [id, isEmoji];
}

class ToggleClapFeed extends FeedEvent {
  const ToggleClapFeed({required this.id, required this.isClap});
  final String id;
  final bool isClap;
  @override
  List<Object?> get props => [id, isClap];
}

class LoadMoreFeeds extends FeedEvent {}
