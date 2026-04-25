import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/features/news/domain/usecases/get_aggregated_news.dart';
import 'package:presshop/features/news/data/datasources/news_socket_datasource.dart';
import 'package:presshop/features/news/domain/usecases/get_comments.dart';
import 'package:presshop/features/news/domain/usecases/get_news_detail.dart';
import 'package:presshop/features/news/presentation/bloc/news_event.dart';
import 'package:presshop/features/news/presentation/bloc/news_state.dart';
import 'package:presshop/features/news/domain/entities/comment.dart';
import 'package:presshop/features/news/data/models/comment_model.dart';
import 'package:presshop/features/news/domain/entities/news.dart';
import 'package:presshop/core/error/failures.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  NewsBloc({
    required this.getAggregatedNews,
    required this.getNewsDetail,
    required this.getComments,
    required this.newsSocketDataSource,
    required this.sharedPreferences,
  }) : super(const NewsState(isLoading: true)) {
    on<GetAggregatedNewsEvent>(_onGetAggregatedNews);
    on<GetNewsDetailEvent>(_onGetNewsDetail);
    on<GetCommentsEvent>(_onGetComments);
    on<AddCommentLocalEvent>(_onAddCommentLocal);
    on<UpdateLikeLocalEvent>(_onUpdateLikeLocal);
    on<ToggleNewsLikeEvent>(_onToggleNewsLike);
    on<OnNewsLikeUpdatedEvent>(_onNewsLikeUpdated);
    on<OnCommentLikeUpdatedEvent>(_onCommentLikeUpdated);
    on<PostCommentEvent>(_onPostComment);
    on<OnCommentNewEvent>(_onCommentNew);
    on<ShareNewsEvent>(_onShareNews);
    on<OnNewsShareUpdatedEvent>(_onNewsShareUpdated);
    on<ViewNewsEvent>(_onViewNews);
    on<GetAllNewsEvent>(_onGetAllNews);
    on<ToggleCommentLikeEvent>(_onToggleCommentLike);
    on<ToggleLikeStatusEvent>(_onToggleLikeStatus);
    on<IncrementViewCountEvent>(_onIncrementViewCount);
    on<UpdateShareCountEvent>(_onUpdateShareCount);

    _initSocketListener();
  }

  void _ensureSocketInitialized() {
    if (!newsSocketDataSource.isInitialized) {
      final userId =
          sharedPreferences.getString(SharedPreferencesKeys.hopperIdKey) ?? '';
      if (userId.isNotEmpty) {
        newsSocketDataSource.initSocket(userId: userId, userType: "hopper");
      }
    }
  }

  final GetAggregatedNews getAggregatedNews;
  final GetNewsDetail getNewsDetail;
  final GetComments getComments;
  final NewsSocketDataSource newsSocketDataSource;
  final SharedPreferences sharedPreferences;

  void _initSocketListener() {
    _ensureSocketInitialized();
    newsSocketDataSource.joinNewsAll();
    newsSocketDataSource.onNewsLike = (data) {
      if (!isClosed) {
        add(OnNewsLikeUpdatedEvent(likeData: data));
      }
    };
    newsSocketDataSource.onCommentLike = (data) {
      if (!isClosed) {
        add(OnCommentLikeUpdatedEvent(likeData: data));
      }
    };
    newsSocketDataSource.onCommentNew = (data) {
      if (!isClosed) {
        add(OnCommentNewEvent(commentData: data));
      }
    };
    newsSocketDataSource.onNewsShare = (data) {
      if (!isClosed) {
        add(OnNewsShareUpdatedEvent(shareData: data));
      }
    };
  }

  @override
  Future<void> close() {
    newsSocketDataSource.onNewsLike = null;
    newsSocketDataSource.onCommentLike = null;
    newsSocketDataSource.onCommentNew = null;
    newsSocketDataSource.onNewsShare = null;
    return super.close();
  }

  void _onCommentLikeUpdated(
    OnCommentLikeUpdatedEvent event,
    Emitter<NewsState> emit,
  ) {
    final data = event.likeData;
    if (data is Map<String, dynamic>) {
      final commentId = data['commentId'];
      final likesCount = data['total_likes'] != null
          ? int.tryParse(data['total_likes'].toString())
          : null;
      final isLiked = data['is_liked'] as bool?;

      if (commentId == null) return;

      final updatedComments = _updateCommentInList(
        state.comments,
        commentId,
        (comment) => comment.copyWith(
          likesCount: likesCount ?? comment.likesCount,
          isLiked: isLiked ?? comment.isLiked,
        ),
      );
      emit(state.copyWith(comments: updatedComments));
    }
  }

  void _onPostComment(
    PostCommentEvent event,
    Emitter<NewsState> emit,
  ) {
    final userId =
        sharedPreferences.getString(SharedPreferencesKeys.hopperIdKey) ?? '';
    if (userId.isEmpty) return;

    _ensureSocketInitialized();

    newsSocketDataSource.addComment(
      contentId: event.contentId,
      text: event.text,
      userId: userId,
      parentId: event.parentId,
      rootParentId: event.rootParentId,
      replyToName: event.replyToName,
    );
  }

  void _onCommentNew(
    OnCommentNewEvent event,
    Emitter<NewsState> emit,
  ) {
    final data = event.commentData;
    if (data is Map<String, dynamic>) {
      try {
        final comment = CommentModel.fromJson(data);
        add(AddCommentLocalEvent(comment: comment, parentId: comment.parentId));

        // Update comment count for the news item in list
        final updatedList = state.newsList.map((news) {
          if (news.id == comment.contentId) {
            return news.copyWith(
              commentsCount: (news.commentsCount ?? 0) + 1,
            );
          }
          return news;
        }).toList();

        // Update comment count for the selected news
        News? updatedSelectedNews = state.selectedNews;
        if (updatedSelectedNews != null &&
            updatedSelectedNews.id == comment.contentId) {
          updatedSelectedNews = updatedSelectedNews.copyWith(
            commentsCount: (updatedSelectedNews.commentsCount ?? 0) + 1,
          );
        }

        emit(state.copyWith(
          newsList: updatedList,
          selectedNews: updatedSelectedNews,
        ));
      } catch (e) {
        // Log error but don't crash
        print('Error parsing comment from socket: $e');
      }
    }
  }

  void _onShareNews(
    ShareNewsEvent event,
    Emitter<NewsState> emit,
  ) {
    final userId =
        sharedPreferences.getString(SharedPreferencesKeys.hopperIdKey);

    _ensureSocketInitialized();
    newsSocketDataSource.shareNews(contentId: event.contentId, userId: userId);
  }

  void _onNewsShareUpdated(
    OnNewsShareUpdatedEvent event,
    Emitter<NewsState> emit,
  ) {
    final data = event.shareData;
    if (data is Map<String, dynamic>) {
      final contentId = data['contentId'] ?? data['_id'];
      final sharesCount = data['total_shares'] != null
          ? int.tryParse(data['total_shares'].toString())
          : null;

      if (contentId == null) return;

      final updatedList = state.newsList.map((news) {
        if (news.id == contentId) {
          return news.copyWith(sharesCount: sharesCount ?? news.sharesCount);
        }
        return news;
      }).toList();

      News? updatedSelectedNews = state.selectedNews;
      if (updatedSelectedNews != null && updatedSelectedNews.id == contentId) {
        updatedSelectedNews = updatedSelectedNews.copyWith(
            sharesCount: sharesCount ?? updatedSelectedNews.sharesCount);
      }

      emit(state.copyWith(
          newsList: updatedList, selectedNews: updatedSelectedNews));
    }
  }

  void _onViewNews(
    ViewNewsEvent event,
    Emitter<NewsState> emit,
  ) {
    _ensureSocketInitialized();
    newsSocketDataSource.viewNews(contentId: event.contentId);
  }

  Future<void> _onGetAggregatedNews(
    GetAggregatedNewsEvent event,
    Emitter<NewsState> emit,
  ) async {
    double lat = event.lat;
    double lng = event.lng;

    // Fallback to shared preferences if location is not provided
    if (lat == 0.0 && lng == 0.0) {
      lat = sharedPreferences.getDouble(SharedPreferencesKeys.currentLat) ?? 0.0;
      lng = sharedPreferences.getDouble(SharedPreferencesKeys.currentLon) ?? 0.0;
    }

    if (event.offset == 0) {
      emit(state.copyWith(
          isLoading: true,
          isProcessing: false,
          newsList: [],
          hasMoreNews: true));
    } else {
      emit(state.copyWith(isLoading: true, isProcessing: false));
    }
    final result = await getAggregatedNews(GetAggregatedNewsParams(
      lat: lat,
      lng: lng,
      km: event.km,
      category: event.category,
      alertType: event.alertType,
      limit: event.limit,
      offset: event.offset,
    ));

    await result.fold(
      (failure) async {
        if (failure is ProcessingFailure) {
          emit(state
              .copyWith(isLoading: false, isProcessing: true, newsList: []));
        } else {
          emit(state.copyWith(
              isLoading: false,
              isProcessing: false,
              errorMessage: "Failed to fetch news"));
        }
      },
      (newsList) async {
        List<News> updatedList;
        if (event.offset > 0) {
          updatedList = List.from(state.newsList)..addAll(newsList);
        } else {
          updatedList = List.from(newsList);
        }

        if (event.prioritizedContentId != null && event.offset == 0) {
          final index =
              updatedList.indexWhere((n) => n.id == event.prioritizedContentId);
          if (index != -1) {
            final item = updatedList.removeAt(index);
            updatedList.insert(0, item);
          } else {
            final detailResult = await getNewsDetail(
                GetNewsDetailParams(id: event.prioritizedContentId!));
            detailResult.fold(
              (_) {},
              (news) {
                if (!updatedList.any((n) => n.id == news.id)) {
                  updatedList.insert(0, news);
                }
              },
            );
          }
        }
        emit(state.copyWith(
          isLoading: false,
          isProcessing: false,
          newsList: updatedList,
          hasMoreNews: newsList.length == event.limit,
        ));
      },
    );
  }

  Future<void> _onGetAllNews(
    GetAllNewsEvent event,
    Emitter<NewsState> emit,
  ) async {
    double lat =
        sharedPreferences.getDouble(SharedPreferencesKeys.currentLat) ?? 0.0;
    double lng =
        sharedPreferences.getDouble(SharedPreferencesKeys.currentLon) ?? 0.0;

    if (event.offset == 0) {
      emit(state.copyWith(
          isLoading: true,
          isProcessing: false,
          newsList: [],
          hasMoreNews: true));
    } else {
      emit(state.copyWith(isLoading: true, isProcessing: false));
    }
    final result = await getAggregatedNews(GetAggregatedNewsParams(
      lat: lat,
      lng: lng,
      km: event.km,
      category: event.category,
      alertType: event.alertType,
      limit: event.limit,
      offset: event.offset,
    ));

    result.fold(
      (failure) {
        if (failure is ProcessingFailure) {
          emit(state
              .copyWith(isLoading: false, isProcessing: true, newsList: []));
        } else {
          emit(state.copyWith(
              isLoading: false,
              isProcessing: false,
              errorMessage: "Failed to fetch all news"));
        }
      },
      (newsList) {
        final List<News> updatedList = event.offset > 0
            ? (List.from(state.newsList)..addAll(newsList))
            : List.from(newsList);
        emit(state.copyWith(
          isLoading: false,
          isProcessing: false,
          newsList: updatedList,
          hasMoreNews: newsList.length == event.limit,
        ));
      },
    );
  }

  Future<void> _onGetNewsDetail(
    GetNewsDetailEvent event,
    Emitter<NewsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await getNewsDetail(GetNewsDetailParams(id: event.id));

    result.fold(
      (failure) => emit(state.copyWith(
          isLoading: false, errorMessage: "Failed to fetch news detail")),
      (news) => emit(state.copyWith(isLoading: false, selectedNews: news)),
    );
  }

  Future<void> _onGetComments(
    GetCommentsEvent event,
    Emitter<NewsState> emit,
  ) async {
    final result = await getComments(GetCommentsParams(
      contentId: event.contentId,
      limit: event.limit,
      offset: event.offset,
    ));

    result.fold(
      (failure) =>
          emit(state.copyWith(errorMessage: "Failed to fetch comments")),
      (comments) {
        final hasMore = comments.length == event.limit;
        if (event.offset > 0) {
          emit(state.copyWith(
            comments: [...state.comments, ...comments],
            hasMoreComments: hasMore,
          ));
        } else {
          emit(state.copyWith(
            comments: comments,
            hasMoreComments: hasMore,
          ));
        }
      },
    );
  }

  void _onAddCommentLocal(
    AddCommentLocalEvent event,
    Emitter<NewsState> emit,
  ) {
    if (event.comment.id.isEmpty) return;

    // Duplicate check
    bool exists = state.comments.any((c) => c.id == event.comment.id) ||
        state.comments
            .any((c) => c.replies.any((r) => r.id == event.comment.id));

    if (exists) return;

    final updatedComments = List<Comment>.from(state.comments);
    final targetParentId = event.comment.rootParentId ?? event.parentId;

    if (targetParentId != null) {
      final parentIndex =
          updatedComments.indexWhere((c) => c.id == targetParentId);

      if (parentIndex != -1) {
        final parent = updatedComments[parentIndex];
        // Double check in replies just in case it's a deep reply
        if (parent.replies.any((r) => r.id == event.comment.id)) return;

        final updatedReplies = List<Comment>.from(parent.replies)
          ..add(event.comment);
        updatedComments[parentIndex] = parent.copyWith(replies: updatedReplies);
      }
    } else {
      updatedComments.insert(0, event.comment);
    }
    emit(state.copyWith(comments: updatedComments));
  }

  void _onUpdateLikeLocal(
    UpdateLikeLocalEvent event,
    Emitter<NewsState> emit,
  ) {
    final updatedComments = _updateCommentInList(
      state.comments,
      event.commentId,
      (comment) => comment.copyWith(likesCount: event.count),
    );
    emit(state.copyWith(comments: updatedComments));
  }

  List<Comment> _updateCommentInList(
    List<Comment> comments,
    String commentId,
    Comment Function(Comment) updateFn,
  ) {
    return comments.map((comment) {
      if (comment.id == commentId) {
        return updateFn(comment);
      } else if (comment.replies.isNotEmpty) {
        return comment.copyWith(
          replies: _updateCommentInList(comment.replies, commentId, updateFn),
        );
      }
      return comment;
    }).toList();
  }

  void _onToggleCommentLike(
    ToggleCommentLikeEvent event,
    Emitter<NewsState> emit,
  ) {
    final userId =
        sharedPreferences.getString(SharedPreferencesKeys.hopperIdKey) ?? '';
    if (userId.isNotEmpty) {
      _ensureSocketInitialized();
      newsSocketDataSource.likeComment(
        contentId: event.contentId,
        commentId: event.commentId,
        userId: userId,
      );

      // Optimistic update
      final updatedComments = _updateCommentInList(
        state.comments,
        event.commentId,
        (comment) {
          final isLiked = !comment.isLiked;
          final count = comment.likesCount + (isLiked ? 1 : -1);
          return comment.copyWith(isLiked: isLiked, likesCount: count);
        },
      );
      emit(state.copyWith(comments: updatedComments));
    }
  }

  void _onToggleLikeStatus(
    ToggleLikeStatusEvent event,
    Emitter<NewsState> emit,
  ) {
    // Placeholder
    emit(state);
  }

  void _onIncrementViewCount(
    IncrementViewCountEvent event,
    Emitter<NewsState> emit,
  ) {
    if (state.selectedNews != null) {
      final currentViews = state.selectedNews!.viewCount ?? 0;
      final updatedNews =
          state.selectedNews!.copyWith(viewCount: currentViews + 1);
      emit(state.copyWith(selectedNews: updatedNews));
    }
  }

  void _onUpdateShareCount(
    UpdateShareCountEvent event,
    Emitter<NewsState> emit,
  ) {
    if (state.selectedNews != null) {
      final updatedNews =
          state.selectedNews!.copyWith(sharesCount: event.count);
      emit(state.copyWith(selectedNews: updatedNews));
    }
  }

  void _onToggleNewsLike(
    ToggleNewsLikeEvent event,
    Emitter<NewsState> emit,
  ) {
    final userId =
        sharedPreferences.getString(SharedPreferencesKeys.hopperIdKey) ?? '';
    if (userId.isNotEmpty) {
      _ensureSocketInitialized();
      newsSocketDataSource.likeNews(userId: userId, contentId: event.contentId);

      final updatedList = state.newsList.map((news) {
        if (news.id == event.contentId) {
          final isLiked = !(news.isLiked ?? false);
          final likesCount = (news.likesCount ?? 0) + (isLiked ? 1 : -1);
          return news.copyWith(isLiked: isLiked, likesCount: likesCount);
        }
        return news;
      }).toList();

      News? updatedSelectedNews = state.selectedNews;
      if (updatedSelectedNews != null &&
          updatedSelectedNews.id == event.contentId) {
        final isLiked = !(updatedSelectedNews.isLiked ?? false);
        final likesCount =
            (updatedSelectedNews.likesCount ?? 0) + (isLiked ? 1 : -1);
        updatedSelectedNews = updatedSelectedNews.copyWith(
            isLiked: isLiked, likesCount: likesCount);
      }

      emit(state.copyWith(
          newsList: updatedList, selectedNews: updatedSelectedNews));
    }
  }

  void _onNewsLikeUpdated(
    OnNewsLikeUpdatedEvent event,
    Emitter<NewsState> emit,
  ) {
    final data = event.likeData;
    if (data is Map<String, dynamic>) {
      final contentId = data['contentId'] ?? data['_id'];
      if (contentId == null) return;

      int? likesCount;
      if (data['total_likes'] != null) {
        likesCount = int.tryParse(data['total_likes'].toString());
      }
      bool? isLiked = data['is_liked'];

      final updatedList = state.newsList.map((news) {
        if (news.id == contentId) {
          return news.copyWith(
            likesCount: likesCount ?? news.likesCount,
            isLiked: isLiked ?? news.isLiked,
          );
        }
        return news;
      }).toList();

      News? updatedSelectedNews = state.selectedNews;
      if (updatedSelectedNews != null && updatedSelectedNews.id == contentId) {
        updatedSelectedNews = updatedSelectedNews.copyWith(
          likesCount: likesCount ?? updatedSelectedNews.likesCount,
          isLiked: isLiked ?? updatedSelectedNews.isLiked,
        );
      }

      emit(state.copyWith(
          newsList: updatedList, selectedNews: updatedSelectedNews));
    }
  }
}
