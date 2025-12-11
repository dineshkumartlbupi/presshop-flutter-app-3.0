import 'package:equatable/equatable.dart';
import '../../domain/entities/content_item.dart';
import '../../domain/entities/hashtag.dart';

abstract class ContentState extends Equatable {
  const ContentState();

  @override
  List<Object> get props => [];
}

class ContentInitial extends ContentState {}

class ContentLoading extends ContentState {}

class MyContentLoaded extends ContentState {
  final List<ContentItem> content;
  final int currentPage;
  final bool hasMore;

  const MyContentLoaded({
    required this.content,
    required this.currentPage,
    this.hasMore = true,
  });

  @override
  List<Object> get props => [content, currentPage, hasMore];
}

class ContentDetailLoaded extends ContentState {
  final ContentItem content;

  const ContentDetailLoaded(this.content);

  @override
  List<Object> get props => [content];
}

class ContentPublished extends ContentState {
  final ContentItem content;

  const ContentPublished(this.content);

  @override
  List<Object> get props => [content];
}

class DraftSaved extends ContentState {
  final ContentItem draft;

  const DraftSaved(this.draft);

  @override
  List<Object> get props => [draft];
}

class MediaUploaded extends ContentState {
  final List<String> mediaUrls;

  const MediaUploaded(this.mediaUrls);

  @override
  List<Object> get props => [mediaUrls];
}

class ContentDeleted extends ContentState {
  final String contentId;

  const ContentDeleted(this.contentId);

  @override
  List<Object> get props => [contentId];
}

class HashtagsSearched extends ContentState {
  final List<Hashtag> hashtags;

  const HashtagsSearched(this.hashtags);

  @override
  List<Object> get props => [hashtags];
}

class TrendingHashtagsLoaded extends ContentState {
  final List<Hashtag> hashtags;

  const TrendingHashtagsLoaded(this.hashtags);

  @override
  List<Object> get props => [hashtags];
}

class ContentError extends ContentState {
  final String message;

  const ContentError(this.message);

  @override
  List<Object> get props => [message];
}
