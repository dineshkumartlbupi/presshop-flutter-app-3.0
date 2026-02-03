import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../../domain/usecases/get_my_content.dart';
import '../../domain/usecases/publish_content.dart';
import '../../domain/usecases/save_draft.dart';
import '../../domain/usecases/upload_media.dart';
import '../../domain/usecases/delete_content.dart';
import '../../domain/usecases/search_hashtags.dart';
import '../../domain/usecases/get_trending_hashtags.dart';
import '../../domain/usecases/get_content_detail.dart';
import '../../domain/usecases/get_media_house_offers.dart';
import '../../domain/usecases/get_content_transactions.dart';
import '../../domain/entities/content_item.dart';
import 'content_event.dart';
import 'content_state.dart';

class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final GetMyContent getMyContent;
  final PublishContent publishContent;
  final SaveDraft saveDraft;
  final UploadMedia uploadMedia;
  final DeleteContent deleteContent;
  final SearchHashtags searchHashtags;
  final GetTrendingHashtags getTrendingHashtags;
  final GetContentDetail getContentDetail;
  final GetMediaHouseOffers getMediaHouseOffers;
  final GetContentTransactions getContentTransactions;

  ContentBloc({
    required this.getMyContent,
    required this.publishContent,
    required this.saveDraft,
    required this.uploadMedia,
    required this.deleteContent,
    required this.searchHashtags,
    required this.getTrendingHashtags,
    required this.getContentDetail,
    required this.getMediaHouseOffers,
    required this.getContentTransactions,
  }) : super(ContentInitial()) {
    on<FetchMyContentEvent>(_onFetchMyContent);
    on<PublishContentEvent>(_onPublishContent);
    on<SaveDraftEvent>(_onSaveDraft);
    on<UploadMediaEvent>(_onUploadMedia);
    on<DeleteContentEvent>(_onDeleteContent);
    on<SearchHashtagsEvent>(_onSearchHashtags);
    on<FetchTrendingHashtagsEvent>(_onFetchTrendingHashtags);
    on<FetchContentDetailEvent>(_onFetchContentDetail);
    on<FetchMediaHouseOffersEvent>(_onFetchMediaHouseOffers);
    on<FetchContentTransactionsEvent>(_onFetchContentTransactions);
  }

  Future<void> _onFetchMyContent(
    FetchMyContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    final currentState = (state is MyContentLoaded)
        ? (state as MyContentLoaded)
        : const MyContentLoaded();

    bool isAll = event.type == 'all';
    List<ContentItem> currentList =
        isAll ? currentState.allContent : currentState.myContent;

    // If data is already loaded and it's not a refresh or pagination, don't fetch
    if (!event.isRefresh && event.page == 1 && currentList.isNotEmpty) {
      // Still need to emit the state to ensure UI is updated if it was in a different state
      emit(currentState);
      return;
    }

    // Only emit loading if we don't have data already for this specific type or if it's a refresh of the first page
    // Always use granular loading flags to prevent state clobbering
    if (isAll) {
      emit(currentState.copyWith(isLoadingAll: true));
    } else {
      emit(currentState.copyWith(isLoadingMy: true));
    }

    final showLoader = event.page == 1 && !event.isRefresh;

    final result = await getMyContent(
      GetMyContentParams(
          page: event.page,
          limit: event.limit,
          params: event.params,
          showLoader: showLoader,
          type: event.type),
    );

    // Re-fetch state as it might have changed while waiting for the API response
    final freshState = (state is MyContentLoaded)
        ? (state as MyContentLoaded)
        : const MyContentLoaded();

    result.fold(
      (failure) {
        debugPrint(
            "DEBUG: ContentBloc FetchMyContent failure: ${failure.message}");
        emit(freshState.copyWith(
          errorMessage: failure.message,
          isLoadingAll: isAll ? false : freshState.isLoadingAll,
          isLoadingMy: isAll ? freshState.isLoadingMy : false,
        ));
      },
      (content) {
        debugPrint(
            "DEBUG: ContentBloc FetchMyContent success, type: ${event.type}, items: ${content.length}");
        List<ContentItem> updatedContent = [];
        List<ContentItem> currentList =
            isAll ? freshState.allContent : freshState.myContent;

        if (event.page > 1) {
          updatedContent = List.from(currentList);
          updatedContent.addAll(content);
        } else {
          updatedContent = content;
        }

        if (isAll) {
          emit(freshState.copyWith(
            allContent: updatedContent,
            allPage: event.page,
            hasMoreAll: content.length >= event.limit,
            isLoadingAll: false,
          ));
        } else {
          emit(freshState.copyWith(
            myContent: updatedContent,
            myPage: event.page,
            hasMoreMy: content.length >= event.limit,
            isLoadingMy: false,
          ));
        }
      },
    );
  }

  Future<void> _onFetchContentDetail(
    FetchContentDetailEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentLoading());
    final result = await getContentDetail(event.contentId);
    result.fold(
      (failure) => emit(ContentError(failure.message)),
      (content) => emit(ContentDetailLoaded(content)),
    );
  }

  Future<void> _onPublishContent(
    PublishContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentLoading());
    final result = await publishContent(PublishContentParams(data: event.data));
    result.fold(
      (failure) => emit(ContentError(failure.message)),
      (content) => emit(ContentPublished(content)),
    );
  }

  Future<void> _onSaveDraft(
    SaveDraftEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentLoading());
    final result = await saveDraft(SaveDraftParams(data: event.data));
    result.fold(
      (failure) => emit(ContentError(failure.message)),
      (draft) => emit(DraftSaved(draft)),
    );
  }

  Future<void> _onUploadMedia(
    UploadMediaEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentLoading());
    final result = await uploadMedia(event.filePaths);
    result.fold(
      (failure) => emit(ContentError(failure.message)),
      (urls) => emit(MediaUploaded(urls)),
    );
  }

  Future<void> _onDeleteContent(
    DeleteContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentLoading());
    final result = await deleteContent(event.contentId);
    result.fold(
      (failure) => emit(ContentError(failure.message)),
      (_) => emit(ContentDeleted(event.contentId)),
    );
  }

  Future<void> _onSearchHashtags(
    SearchHashtagsEvent event,
    Emitter<ContentState> emit,
  ) async {
    final result = await searchHashtags(event.query);
    result.fold(
      (failure) => emit(ContentError(failure.message)),
      (hashtags) => emit(HashtagsSearched(hashtags)),
    );
  }

  Future<void> _onFetchTrendingHashtags(
    FetchTrendingHashtagsEvent event,
    Emitter<ContentState> emit,
  ) async {
    final result = await getTrendingHashtags(NoParams());
    result.fold(
      (failure) => emit(ContentError(failure.message)),
      (hashtags) => emit(TrendingHashtagsLoaded(hashtags)),
    );
  }

  Future<void> _onFetchMediaHouseOffers(
    FetchMediaHouseOffersEvent event,
    Emitter<ContentState> emit,
  ) async {
    // emit(ContentLoading()); // Optional: might not want to show full page loader for this
    final result = await getMediaHouseOffers(event.contentId);
    result.fold(
      (failure) => emit(ContentError(failure.message)),
      (offers) => emit(MediaHouseOffersLoaded(offers)),
    );
  }

  Future<void> _onFetchContentTransactions(
    FetchContentTransactionsEvent event,
    Emitter<ContentState> emit,
  ) async {
    // emit(ContentLoading()); // Optional
    final result = await getContentTransactions(GetContentTransactionsParams(
      contentId: event.contentId,
      limit: event.limit,
      offset: event.offset,
    ));
    result.fold(
      (failure) => emit(ContentError(failure.message)),
      (transactions) => emit(ContentTransactionsLoaded(transactions)),
    );
  }
}
