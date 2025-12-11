import 'package:equatable/equatable.dart';
import '../../domain/entities/feed.dart';

enum FeedStatus { initial, loading, success, failure }
enum FeedInteractionStatus { initial, loading, success, failure }

class FeedState extends Equatable {
  final FeedStatus status;
  final List<Feed> feeds;
  final bool hasReachedMax;
  final String errorMessage;
  final FeedInteractionStatus interactionStatus;
  
  // Filter states
  final Map<String, dynamic> filters;

  const FeedState({
    this.status = FeedStatus.initial,
    this.feeds = const [],
    this.hasReachedMax = false,
    this.errorMessage = '',
    this.interactionStatus = FeedInteractionStatus.initial,
    this.filters = const {"limit": "10", "offset": "0"},
  });

  FeedState copyWith({
    FeedStatus? status,
    List<Feed>? feeds,
    bool? hasReachedMax,
    String? errorMessage,
    FeedInteractionStatus? interactionStatus,
    Map<String, dynamic>? filters,
  }) {
    return FeedState(
      status: status ?? this.status,
      feeds: feeds ?? this.feeds,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      interactionStatus: interactionStatus ?? this.interactionStatus,
      filters: filters ?? this.filters,
    );
  }

  @override
  List<Object> get props => [status, feeds, hasReachedMax, errorMessage, interactionStatus, filters];
}
