import 'package:equatable/equatable.dart';

abstract class PublishEvent extends Equatable {
  const PublishEvent();

  @override
  List<Object?> get props => [];
}

class LoadPublishDataEvent extends PublishEvent {
  const LoadPublishDataEvent({this.country});
  final String? country;

  @override
  List<Object?> get props => [country];
}

class SelectCategoryEvent extends PublishEvent {
  const SelectCategoryEvent(this.categoryId);
  final String categoryId;

  @override
  List<Object> get props => [categoryId];
}

class FetchCharitiesEvent extends PublishEvent {
  const FetchCharitiesEvent({this.offset = 0, this.limit = 10});
  final int offset;
  final int limit;

  @override
  List<Object> get props => [offset, limit];
}

class ToggleCharityEvent extends PublishEvent {
  const ToggleCharityEvent(this.isSelected);
  final bool isSelected;

  @override
  List<Object> get props => [isSelected];
}

class SelectCharityEvent extends PublishEvent {
  const SelectCharityEvent(this.charityId);
  final String charityId;

  @override
  List<Object> get props => [charityId];
}

class SubmitContentEvent extends PublishEvent {
  const SubmitContentEvent(this.params, this.filePaths);
  final Map<String, dynamic> params;
  final List<String> filePaths;

  @override
  List<Object> get props => [params, filePaths];
}
