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
  final List<ContentItem> allContent;
  final List<ContentItem> myContent;
  final int allPage;
  final int myPage;
  final bool hasMoreAll;
  final bool hasMoreMy;
  final String? errorMessage;
  final bool isLoadingAll;
  final bool isLoadingMy;

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

class ContentDetailLoaded extends MyContentLoaded {
  final ContentItem content;

  const ContentDetailLoaded(
    this.content, {
    super.allContent,
    super.myContent,
    super.allPage,
    super.myPage,
    super.hasMoreAll,
    super.hasMoreMy,
    super.isLoadingAll,
    super.isLoadingMy,
  });

  @override
  List<Object> get props => [
        content,
        allContent,
        myContent,
        allPage,
        myPage,
        hasMoreAll,
        hasMoreMy,
        isLoadingAll,
        isLoadingMy,
      ];
}

class ContentPublished extends ContentState {
  const ContentPublished(this.content);
  final ContentItem content;

  @override
  List<Object> get props => [content];
}

class DraftSaved extends ContentState {
  const DraftSaved(this.draft);
  final ContentItem draft;

  @override
  List<Object> get props => [draft];
}

class MediaUploaded extends ContentState {
  const MediaUploaded(this.mediaUrls);
  final List<String> mediaUrls;

  @override
  List<Object> get props => [mediaUrls];
}

class ContentDeleted extends ContentState {
  const ContentDeleted(this.contentId);
  final String contentId;

  @override
  List<Object> get props => [contentId];
}

class HashtagsSearched extends ContentState {
  const HashtagsSearched(this.hashtags);
  final List<Hashtag> hashtags;

  @override
  List<Object> get props => [hashtags];
}

class TrendingHashtagsLoaded extends ContentState {
  const TrendingHashtagsLoaded(this.hashtags);
  final List<Hashtag> hashtags;

  @override
  List<Object> get props => [hashtags];
}

class MediaHouseOffersLoaded extends MyContentLoaded {
  final List<ManageTaskChatModel> offers;

  const MediaHouseOffersLoaded(
    this.offers, {
    super.allContent,
    super.myContent,
    super.allPage,
    super.myPage,
    super.hasMoreAll,
    super.hasMoreMy,
    super.isLoadingAll,
    super.isLoadingMy,
  });

  @override
  List<Object> get props => [
        offers,
        allContent,
        myContent,
        allPage,
        myPage,
        hasMoreAll,
        hasMoreMy,
        isLoadingAll,
        isLoadingMy,
      ];
}

class ContentTransactionsLoaded extends MyContentLoaded {
  final List<EarningTransactionDetail> transactions;

  const ContentTransactionsLoaded(
    this.transactions, {
    super.allContent,
    super.myContent,
    super.allPage,
    super.myPage,
    super.hasMoreAll,
    super.hasMoreMy,
    super.isLoadingAll,
    super.isLoadingMy,
  });

  @override
  List<Object> get props => [
        transactions,
        allContent,
        myContent,
        allPage,
        myPage,
        hasMoreAll,
        hasMoreMy,
        isLoadingAll,
        isLoadingMy,
      ];
}

class ContentError extends MyContentLoaded {
  final String message;

  const ContentError(
    this.message, {
    super.allContent,
    super.myContent,
    super.allPage,
    super.myPage,
    super.hasMoreAll,
    super.hasMoreMy,
    super.isLoadingAll,
    super.isLoadingMy,
  });

  @override
  List<Object> get props => [
        message,
        allContent,
        myContent,
        allPage,
        myPage,
        hasMoreAll,
        hasMoreMy,
        isLoadingAll,
        isLoadingMy,
      ];
}
