import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/features/map/data/services/socket_service.dart';
import 'package:presshop/features/news/domain/usecases/get_aggregated_news.dart';
import 'package:presshop/features/news/domain/usecases/get_comments.dart';
import 'package:presshop/features/news/domain/usecases/get_news_detail.dart';
import 'package:presshop/features/news/presentation/bloc/news_event.dart';
import 'package:presshop/features/news/presentation/bloc/news_state.dart';
import 'package:presshop/features/news/domain/entities/comment.dart';
import 'package:presshop/features/news/domain/entities/news.dart';
import 'package:presshop/core/error/failures.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  NewsBloc({
    required this.getAggregatedNews,
    required this.getNewsDetail,
    required this.getComments,
    required this.socketService,
    required this.sharedPreferences,
  }) : super(const NewsState()) {
    on<GetAggregatedNewsEvent>(_onGetAggregatedNews);
    on<GetNewsDetailEvent>(_onGetNewsDetail);
    on<GetCommentsEvent>(_onGetComments);
    on<AddCommentLocalEvent>(_onAddCommentLocal);
    on<UpdateLikeLocalEvent>(_onUpdateLikeLocal);
    on<ToggleLikeStatusEvent>(_onToggleLikeStatus);
    on<IncrementViewCountEvent>(_onIncrementViewCount);
    on<UpdateShareCountEvent>(_onUpdateShareCount);
    on<ToggleNewsLikeEvent>(_onToggleNewsLike);
    on<OnNewsLikeUpdatedEvent>(_onNewsLikeUpdated);
    on<ToggleCommentLikeEvent>(_onToggleCommentLike);

    _initSocketListener();
  }
  final GetAggregatedNews getAggregatedNews;
  final GetNewsDetail getNewsDetail;
  final GetComments getComments;
  final SocketService socketService;
  final SharedPreferences sharedPreferences;

  void _initSocketListener() {
    socketService.onNewsLike = (data) {
      add(OnNewsLikeUpdatedEvent(likeData: data));
    };
  }

  Future<void> _onGetAggregatedNews(
    GetAggregatedNewsEvent event,
    Emitter<NewsState> emit,
  ) async {
    double lat = event.lat;
    double lng = event.lng;

    // Fallback to shared preferences if location is not provided
    if (lat == 0.0 && lng == 0.0) {
      lat = sharedPreferences.getDouble(currentLat) ?? 0.0;
      lng = sharedPreferences.getDouble(currentLon) ?? 0.0;
    }

    emit(state.copyWith(isLoading: true, isProcessing: false));
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
              errorMessage: "Failed to fetch news"));
        }
      },
      (newsList) => emit(state.copyWith(
          isLoading: false, isProcessing: false, newsList: newsList)),
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
    final updatedComments = List<Comment>.from(state.comments);
    if (event.parentId != null) {
      final parentIndex =
          updatedComments.indexWhere((c) => c.id == event.parentId);
      if (parentIndex != -1) {
        final parent = updatedComments[parentIndex];
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
    final userId = sharedPreferences.getString(hopperIdKey) ?? '';
    if (userId.isNotEmpty) {
      socketService.likeComment(
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
    final userId = sharedPreferences.getString(hopperIdKey) ?? '';
    if (userId.isNotEmpty) {
      socketService.likeNews(userId: userId, contentId: event.contentId);

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
