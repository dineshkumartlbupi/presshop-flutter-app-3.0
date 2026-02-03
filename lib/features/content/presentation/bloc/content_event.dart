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
  final bool isRefresh;
  final String type; // 'all' or 'my'

  const FetchMyContentEvent({
    this.page = 1,
    this.limit = 20,
    this.params = const {},
    this.isRefresh = false,
    this.type = 'all',
  });

  @override
  List<Object> get props => [page, limit, params, isRefresh, type];
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

class FetchMediaHouseOffersEvent extends ContentEvent {
  final String contentId;

  const FetchMediaHouseOffersEvent(this.contentId);

  @override
  List<Object> get props => [contentId];
}

class FetchContentTransactionsEvent extends ContentEvent {
  final String contentId;
  final int limit;
  final int offset;

  const FetchContentTransactionsEvent(
      {required this.contentId, required this.limit, required this.offset});

  @override
  List<Object> get props => [contentId, limit, offset];
}
