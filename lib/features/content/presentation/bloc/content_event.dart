import 'package:equatable/equatable.dart';

abstract class ContentEvent extends Equatable {
  const ContentEvent();

  @override
  List<Object> get props => [];
}

class FetchMyContentEvent extends ContentEvent {
  final int page;
  final int limit;
  final Map<String, dynamic> params;

  const FetchMyContentEvent({this.page = 1, this.limit = 20, this.params = const {}});

  @override
  List<Object> get props => [page, limit, params];
}

class PublishContentEvent extends ContentEvent {
  final Map<String, dynamic> data;

  const PublishContentEvent(this.data);

  @override
  List<Object> get props => [data];
}

class SaveDraftEvent extends ContentEvent {
  final Map<String, dynamic> data;

  const SaveDraftEvent(this.data);

  @override
  List<Object> get props => [data];
}

class UploadMediaEvent extends ContentEvent {
  final List<String> filePaths;

  const UploadMediaEvent(this.filePaths);

  @override
  List<Object> get props => [filePaths];
}

class DeleteContentEvent extends ContentEvent {
  final String contentId;

  const DeleteContentEvent(this.contentId);

  @override
  List<Object> get props => [contentId];
}

class SearchHashtagsEvent extends ContentEvent {
  final String query;

  const SearchHashtagsEvent(this.query);

  @override
  List<Object> get props => [query];
}

class FetchTrendingHashtagsEvent extends ContentEvent {}

class FetchContentDetailEvent extends ContentEvent {
  final String contentId;

  const FetchContentDetailEvent(this.contentId);

  @override
  List<Object> get props => [contentId];
}
