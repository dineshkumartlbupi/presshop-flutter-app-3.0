import 'package:equatable/equatable.dart';
import '../../domain/entities/content_item.dart';
import '../../domain/entities/hashtag.dart';
import 'package:presshop/features/task/data/models/manage_task_chat_model.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';

abstract class ContentState extends Equatable {
  const ContentState();

  @override
  List<Object> get props => [];
}

class ContentInitial extends ContentState {}

class ContentLoading extends ContentState {}

class MyContentLoaded extends ContentState {
  final List<ContentItem> allContent;
  final List<ContentItem> myContent;
  final int allPage;
  final int myPage;
  final bool hasMoreAll;
  final bool hasMoreMy;
  final String? errorMessage;
  final bool isLoadingAll;
  final bool isLoadingMy;

  const MyContentLoaded({
    this.allContent = const [],
    this.myContent = const [],
    this.allPage = 1,
    this.myPage = 1,
    this.hasMoreAll = true,
    this.hasMoreMy = true,
    this.errorMessage,
    this.isLoadingAll = false,
    this.isLoadingMy = false,
  });

  @override
  List<Object> get props => [
        allContent,
        myContent,
        allPage,
        myPage,
        hasMoreAll,
        hasMoreMy,
        errorMessage ?? '',
        isLoadingAll,
        isLoadingMy,
      ];

  MyContentLoaded copyWith({
    List<ContentItem>? allContent,
    List<ContentItem>? myContent,
    int? allPage,
    int? myPage,
    bool? hasMoreAll,
    bool? hasMoreMy,
    String? errorMessage,
    bool? isLoadingAll,
    bool? isLoadingMy,
  }) {
    return MyContentLoaded(
      allContent: allContent ?? this.allContent,
      myContent: myContent ?? this.myContent,
      allPage: allPage ?? this.allPage,
      myPage: myPage ?? this.myPage,
      hasMoreAll: hasMoreAll ?? this.hasMoreAll,
      hasMoreMy: hasMoreMy ?? this.hasMoreMy,
      errorMessage: errorMessage,
      isLoadingAll: isLoadingAll ?? this.isLoadingAll,
      isLoadingMy: isLoadingMy ?? this.isLoadingMy,
    );
  }
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

class MediaHouseOffersLoaded extends ContentState {
  final List<ManageTaskChatModel> offers;

  const MediaHouseOffersLoaded(this.offers);

  @override
  List<Object> get props => [offers];
}

class ContentTransactionsLoaded extends ContentState {
  final List<EarningTransactionDetail> transactions;

  const ContentTransactionsLoaded(this.transactions);

  @override
  List<Object> get props => [transactions];
}

class ContentError extends ContentState {
  final String message;

  const ContentError(this.message);

  @override
  List<Object> get props => [message];
}
