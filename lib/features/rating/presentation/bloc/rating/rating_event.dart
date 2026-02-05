part of 'rating_bloc.dart';

abstract class RatingEvent extends Equatable {
  const RatingEvent();

  @override
  List<Object> get props => [];
}

class RatingLoadInitial extends RatingEvent {}

class RatingLoadReviews extends RatingEvent {

  const RatingLoadReviews({this.isRefresh = false, this.isLoadMore = false});
  final bool isRefresh;
  final bool isLoadMore;
}

class RatingTypeChanged extends RatingEvent { // 'Received' or 'Given'

  const RatingTypeChanged(this.type);
  final String type;

  @override
  List<Object> get props => [type];
}

class RatingFilterUpdated extends RatingEvent {

  const RatingFilterUpdated(this.filters);
  final Map<String, dynamic> filters;

  @override
  List<Object> get props => [filters];
}
