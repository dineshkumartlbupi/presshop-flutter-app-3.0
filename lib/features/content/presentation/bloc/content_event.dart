import 'package:equatable/equatable.dart';

abstract class ContentEvent extends Equatable {
  const ContentEvent();

  @override
  List<Object> get props => [];
}

class FetchMyContentEvent extends ContentEvent {
  // 'all' or 'my'

  const FetchMyContentEvent({
    this.page = 1,
    this.limit = 20,
    this.params = const {},
    this.isRefresh = false,
    this.type = 'all',
  });
  final int page;
  final int limit;
  final Map<String, dynamic> params;
  final bool isRefresh;
  final String type;

  @override
  List<Object> get props => [page, limit, params, isRefresh, type];
}

class PublishContentEvent extends ContentEvent {
  const PublishContentEvent(this.data);
  final Map<String, dynamic> data;

  @override
  List<Object> get props => [data];
}

class SaveDraftEvent extends ContentEvent {
  const SaveDraftEvent(this.data);
  final Map<String, dynamic> data;

  @override
  List<Object> get props => [data];
}

class UploadMediaEvent extends ContentEvent {
  const UploadMediaEvent(this.filePaths);
  final List<String> filePaths;

  @override
  List<Object> get props => [filePaths];
}

class DeleteContentEvent extends ContentEvent {
  const DeleteContentEvent(this.contentId);
  final String contentId;

  @override
  List<Object> get props => [contentId];
}

class SearchHashtagsEvent extends ContentEvent {
  const SearchHashtagsEvent(this.query);
  final String query;

  @override
  List<Object> get props => [query];
}

class FetchTrendingHashtagsEvent extends ContentEvent {}

class FetchContentDetailEvent extends ContentEvent {
  const FetchContentDetailEvent(this.contentId);
  final String contentId;

  @override
  List<Object> get props => [contentId];
}

class FetchMediaHouseOffersEvent extends ContentEvent {
  const FetchMediaHouseOffersEvent(this.contentId);
  final String contentId;

  @override
  List<Object> get props => [contentId];
}

class FetchContentTransactionsEvent extends ContentEvent {
  const FetchContentTransactionsEvent(
      {required this.contentId, required this.limit, required this.offset});
  final String contentId;
  final int limit;
  final int offset;

  @override
  List<Object> get props => [contentId, limit, offset];
}

class RecordContentViewEvent extends ContentEvent {
  final String contentId;
  final String userId;

  const RecordContentViewEvent({required this.contentId, required this.userId});

  @override
  List<Object> get props => [contentId, userId];
}

class OnContentViewRecordedBroadcast extends ContentEvent {
  final Map<String, dynamic> data;

  const OnContentViewRecordedBroadcast(this.data);

  @override
  List<Object> get props => [data];
}
