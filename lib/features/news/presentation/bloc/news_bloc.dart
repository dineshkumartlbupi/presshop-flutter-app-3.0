import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/features/news/domain/usecases/get_aggregated_news.dart';
import 'package:presshop/features/news/domain/usecases/get_comments.dart';
import 'package:presshop/features/news/domain/usecases/get_news_detail.dart';
import 'package:presshop/features/news/presentation/bloc/news_event.dart';
import 'package:presshop/features/news/presentation/bloc/news_state.dart';
import 'package:presshop/features/news/domain/entities/comment.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final GetAggregatedNews getAggregatedNews;
  final GetNewsDetail getNewsDetail;
  final GetComments getComments;

  NewsBloc({
    required this.getAggregatedNews,
    required this.getNewsDetail,
    required this.getComments,
  }) : super(const NewsState()) {
    on<GetAggregatedNewsEvent>(_onGetAggregatedNews);
    on<GetNewsDetailEvent>(_onGetNewsDetail);
    on<GetCommentsEvent>(_onGetComments);
    on<AddCommentLocalEvent>(_onAddCommentLocal);
    on<UpdateLikeLocalEvent>(_onUpdateLikeLocal);
    on<ToggleLikeStatusEvent>(_onToggleLikeStatus);
    on<IncrementViewCountEvent>(_onIncrementViewCount);
    on<UpdateShareCountEvent>(_onUpdateShareCount);
  }

  Future<void> _onGetAggregatedNews(
    GetAggregatedNewsEvent event,
    Emitter<NewsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await getAggregatedNews(GetAggregatedNewsParams(
      lat: event.lat,
      lng: event.lng,
      km: event.km,
      category: event.category,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
          isLoading: false, errorMessage: "Failed to fetch news")),
      (newsList) => emit(state.copyWith(isLoading: false, newsList: newsList)),
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
    ));

    result.fold(
      (failure) =>
          emit(state.copyWith(errorMessage: "Failed to fetch comments")),
      (comments) => emit(state.copyWith(comments: comments)),
    );
  }

  void _onAddCommentLocal(
    AddCommentLocalEvent event,
    Emitter<NewsState> emit,
  ) {
    final updatedComments = List<Comment>.from(state.comments);
    if (event.parentId != null) {
      // Find parent and add reply
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
    final updatedComments = state.comments.map((c) {
      if (c.id == event.commentId) {
        // return c.copyWith(likes: event.count); // Assuming copyWith exists
        return c; // Placeholder until Comment entity has copyWith
      }
      return c;
    }).toList();
    emit(state.copyWith(comments: updatedComments));
  }

  void _onToggleLikeStatus(
    ToggleLikeStatusEvent event,
    Emitter<NewsState> emit,
  ) {
    final updatedComments = state.comments.map((c) {
      if (c.id == event.commentId) {
        // return c.copyWith(isLiked: event.isLiked);
        return c;
      }
      return c;
    }).toList();
    emit(state.copyWith(comments: updatedComments));
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
}
