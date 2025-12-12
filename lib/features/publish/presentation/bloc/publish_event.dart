import 'package:equatable/equatable.dart';

abstract class PublishEvent extends Equatable {
  const PublishEvent();

  @override
  List<Object?> get props => [];
}

class LoadPublishDataEvent extends PublishEvent {}

class SelectCategoryEvent extends PublishEvent {
  final String categoryId;
  const SelectCategoryEvent(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class FetchCharitiesEvent extends PublishEvent {
  final int offset;
  final int limit;
  const FetchCharitiesEvent({this.offset = 0, this.limit = 10});

  @override
  List<Object> get props => [offset, limit];
}

class ToggleCharityEvent extends PublishEvent {
  final bool isSelected;
  const ToggleCharityEvent(this.isSelected);

  @override
  List<Object> get props => [isSelected];
}

class SelectCharityEvent extends PublishEvent {
  final String charityId;
  const SelectCharityEvent(this.charityId);

  @override
  List<Object> get props => [charityId];
}

class SubmitContentEvent extends PublishEvent {
  final Map<String, dynamic> params;
  const SubmitContentEvent(this.params);

  @override
  List<Object> get props => [params];
}
