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
    emit(ContentLoading());
    final result = await getMyContent(
      GetMyContentParams(
          page: event.page, limit: event.limit, params: event.params),
    );
    result.fold(
      (failure) => emit(ContentError(failure.message)),
      (content) => emit(MyContentLoaded(
        content: content,
        currentPage: event.page,
        hasMore: content.length >= event.limit,
      )),
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
