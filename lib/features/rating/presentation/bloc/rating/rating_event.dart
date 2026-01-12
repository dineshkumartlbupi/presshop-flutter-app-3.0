part of 'rating_bloc.dart';

abstract class RatingEvent extends Equatable {
  const RatingEvent();

  @override
  List<Object> get props => [];
}

class RatingLoadInitial extends RatingEvent {}

class RatingLoadReviews extends RatingEvent {
  final bool isRefresh;
  final bool isLoadMore;

  const RatingLoadReviews({this.isRefresh = false, this.isLoadMore = false});
}

class RatingTypeChanged extends RatingEvent {
  final String type; // 'Received' or 'Given'

  const RatingTypeChanged(this.type);

  @override
  List<Object> get props => [type];
}

class RatingFilterUpdated extends RatingEvent {
  final Map<String, dynamic> filters;

  const RatingFilterUpdated(this.filters);

  @override
  List<Object> get props => [filters];
}
