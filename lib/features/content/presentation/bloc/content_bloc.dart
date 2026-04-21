import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:presshop/core/utils/app_logger.dart';
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
import '../../domain/usecases/record_content_view.dart';
import '../../data/datasources/content_socket_datasource.dart';
import '../../domain/entities/content_item.dart';
import '../../domain/entities/category_data.dart';
import '../../domain/entities/content_metadata.dart';
import 'content_event.dart';
import 'content_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presshop/core/utils/shared_preferences.dart';

class ContentBloc extends Bloc<ContentEvent, ContentState> {
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
    required this.recordContentView,
    required this.contentSocketDataSource,
    required this.sharedPreferences,
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
    on<RecordContentViewEvent>(_onRecordContentView);
    on<OnContentViewRecordedBroadcast>(_onContentViewRecordedBroadcast);

    _initSocket();
  }
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
  final RecordContentView recordContentView;
  final ContentSocketDataSource contentSocketDataSource;
  final SharedPreferences sharedPreferences;

  void _initSocket() {
    final userId =
        sharedPreferences.getString(SharedPreferencesKeys.hopperIdKey) ?? '';
    if (userId.isNotEmpty) {
      contentSocketDataSource.initSocket(userId: userId, userType: "hopper");
    }

    contentSocketDataSource.listenToViewRecorded(onData: (data) {
      add(OnContentViewRecordedBroadcast(data));
    });
  }

  @override
  Future<void> close() {
    contentSocketDataSource.stopListeningToViewRecorded();
    return super.close();
  }

  Future<void> _onFetchMyContent(
    FetchMyContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    final currentState = (state is MyContentLoaded)
        ? (state as MyContentLoaded)
        : const MyContentLoaded();

    bool isAll = event.type == 'all';

    final cacheBox = Hive.box('sync_cache');
    final String cacheKey = 'content_${event.type}';

    if (event.page == 1) {
      final cachedData = cacheBox.get(cacheKey);
      if (cachedData != null && cachedData is List) {
        try {
          // Robust parsing for cached content items
          final List<ContentItem> items = cachedData.map((e) {
            return ContentItem(
              id: (e['id'] ?? '').toString(),
              description: (e['description'] ?? '').toString(),
              location: (e['location'] ?? '').toString(),
              latitude: (e['latitude'] ?? '').toString(),
              longitude: (e['longitude'] ?? '').toString(),
              categoryId: (e['category_id'] ?? '').toString(),
              hopperId: (e['hopper_id'] ?? '').toString(),
              type: e['type']?.toString(),
              askPrice: (e['ask_price'] ?? '').toString(),
              isDraft: e['is_draft'] ?? false,
              isCharity: e['is_charity'] ?? false,
              images: List<String>.from(e['images'] ?? []),
              videos: List<dynamic>.from(e['videos'] ?? []),
              createdAt: (e['created_at'] ?? e['timestamp'] ?? '').toString(),
              status: (e['status'] ??
                      (e['is_draft'] == true ? 'draft' : 'published'))
                  .toString(),
              contentMetadata: (e['content_metadata'] as List? ?? [])
                  .map((m) => m is Map
                      ? ContentMetadata(
                          media: (m['media'] ?? '').toString(),
                          isNsfw: m['is_nsfw'] ?? false,
                          deepFake: m['deep_fake'] ?? false,
                          thumbnail: (m['thumbnail'] ?? '').toString(),
                          mediaType: (m['media_type'] ?? '').toString(),
                          isWatermarked: m['is_watermarked'] ?? false,
                          originalFileName:
                              (m['original_file_name'] ?? '').toString(),
                          watermarkedMedia:
                              (m['watermarked_media'] ?? '').toString(),
                          watermark: (m['watermark'] ?? '').toString(),
                        )
                      : const ContentMetadata(
                          media: '',
                          isNsfw: false,
                          deepFake: false,
                          thumbnail: '',
                          mediaType: '',
                          isWatermarked: false,
                          originalFileName: '',
                          watermarkedMedia: '',
                          watermark: '',
                        ))
                  .toList(),
              productId: (e['product_id'] ?? '').toString(),
              priceOriginal: (e['price_original'] ?? '').toString(),
              convertedAskPrice: (e['converted_ask_price'] ?? '').toString(),
              currencyOriginal: (e['currency_original'] ?? '').toString(),
              priceBase: e['price_base']?.toString(),
              currencyBase: e['currency_base']?.toString(),
              imageCount: e['image_count'] ?? 0,
              videoCount: e['video_count'] ?? 0,
              audioCount: e['audio_count'],
              otherCount: e['other_count'],
              contentUnderOffer: e['content_under_offer'] ?? false,
              paidStatus: e['paid_status'] ?? false,
              contentViewCount: e['content_view_count'] ?? 0,
              isFavourite: e['is_favourite'] ?? false,
              isLiked: e['is_liked'] ?? false,
              isEmoji: e['is_emoji'] == true,
              isClap: e['is_clap'] == true,
              updatedAt: e['updated_at']?.toString(),
              categoryData: CategoryData(
                id: (e['categoryData']?['id'] ??
                        e['category_data']?['id'] ??
                        '')
                    .toString(),
                name: (e['categoryData']?['name'] ??
                        e['category_data']?['name'] ??
                        '')
                    .toString(),
                icon:
                    (e['categoryData']?['icon'] ?? e['category_data']?['icon'])
                        ?.toString(),
                percentage: (e['categoryData']?['percentage'] ??
                        e['category_data']?['percentage'] ??
                        '')
                    .toString(),
                type: (e['categoryData']?['type'] ??
                        e['category_data']?['type'] ??
                        '')
                    .toString(),
              ),
              purchasedMediahouseCount: int.tryParse(
                      e['purchased_mediahouse_count']?.toString() ?? '0') ??
                  0,
              totalOffer:
                  int.tryParse(e['total_offer']?.toString() ?? '0') ?? 0,
              isExclusive: e['is_exclusive'] == true,
              isPaidStatusToHopper: e['is_paid_status_to_hopper'] == true,
              currency: (e['currency'] ?? '').toString(),
              currencySymbol: (e['currency_symbol'] ?? '').toString(),
            );
          }).toList();

          if (items.isNotEmpty) {
            emit(isAll
                ? currentState.copyWith(allContent: items, isLoadingAll: false)
                : currentState.copyWith(myContent: items, isLoadingMy: false));
          }
        } catch (e) {
          debugPrint("Error loading content from cache: $e");
        }
      }
    }

    // Only emit loading if we don't have data already for this specific type or if it's a refresh of the first page
    if (isAll) {
      if (currentState.allContent.isEmpty) {
        emit(currentState.copyWith(isLoadingAll: true));
      }
    } else {
      if (currentState.myContent.isEmpty) {
        emit(currentState.copyWith(isLoadingMy: true));
      }
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

    // Re-fetch state
    final freshState = (state is MyContentLoaded)
        ? (state as MyContentLoaded)
        : const MyContentLoaded();

    result.fold(
      (failure) {
        if ((isAll && freshState.allContent.isEmpty) ||
            (!isAll && freshState.myContent.isEmpty)) {
          emit(freshState.copyWith(
            errorMessage: failure.message,
            isLoadingAll: isAll ? false : freshState.isLoadingAll,
            isLoadingMy: isAll ? freshState.isLoadingMy : false,
          ));
        }
      },
      (content) {
        if (event.page == 1) {
          cacheBox.put(cacheKey, content.map((e) => e.toJson()).toList());
        }

        List<ContentItem> updatedContent = [];
        List<ContentItem> currentList =
            isAll ? freshState.allContent : freshState.myContent;

        if (event.page > 1) {
          updatedContent = List.from(currentList);
          final existingIds = updatedContent.map((e) => e.id).toSet();
          updatedContent
              .addAll(content.where((e) => !existingIds.contains(e.id)));
        } else {
          final Set<String> ids = {};
          for (var e in content) {
            if (ids.add(e.id)) {
              updatedContent.add(e);
            }
          }
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
    // DO NOT emit(ContentLoading()); as it wipes the list state
    final currentState = (state is MyContentLoaded)
        ? (state as MyContentLoaded)
        : const MyContentLoaded();

    final result = await getContentDetail(
        GetContentDetailParams(event.contentId, showLoader: false));
    result.fold(
      (failure) => emit(ContentError(
        failure.message,
        allContent: currentState.allContent,
        myContent: currentState.myContent,
        allPage: currentState.allPage,
        myPage: currentState.myPage,
        hasMoreAll: currentState.hasMoreAll,
        hasMoreMy: currentState.hasMoreMy,
        isLoadingAll: currentState.isLoadingAll,
        isLoadingMy: currentState.isLoadingMy,
      )),
      (content) {
        AppLogger.trackEvent(EventNames.contentViewed, parameters: {
          'content_id': event.contentId,
          'content_type': content.type ?? 'unknown',
        });
        emit(ContentDetailLoaded(
          content,
          allContent: currentState.allContent,
          myContent: currentState.myContent,
          allPage: currentState.allPage,
          myPage: currentState.myPage,
          hasMoreAll: currentState.hasMoreAll,
          hasMoreMy: currentState.hasMoreMy,
          isLoadingAll: currentState.isLoadingAll,
          isLoadingMy: currentState.isLoadingMy,
        ));
      },
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
      (content) {
        AppLogger.trackEvent(EventNames.contentPublished, parameters: {
          'content_id': content.id,
          'content_type': content.type ?? 'unknown',
        });
        emit(ContentPublished(content));
      },
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
      (_) {
        AppLogger.trackEvent(EventNames.contentDeleted, parameters: {
          'content_id': event.contentId,
        });
        emit(ContentDeleted(event.contentId));
      },
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
    final currentState = (state is MyContentLoaded)
        ? (state as MyContentLoaded)
        : const MyContentLoaded();

    final result = await getMediaHouseOffers(
        GetMediaHouseOffersParams(event.contentId, showLoader: false));
    result.fold(
      (failure) {
        debugPrint(
            "DEBUG: ContentBloc FetchMediaHouseOffers failure: ${failure.message}");
        emit(currentState);
      },
      (offers) => emit(MediaHouseOffersLoaded(
        offers,
        allContent: currentState.allContent,
        myContent: currentState.myContent,
        allPage: currentState.allPage,
        myPage: currentState.myPage,
        hasMoreAll: currentState.hasMoreAll,
        hasMoreMy: currentState.hasMoreMy,
        isLoadingAll: currentState.isLoadingAll,
        isLoadingMy: currentState.isLoadingMy,
      )),
    );
  }

  Future<void> _onFetchContentTransactions(
    FetchContentTransactionsEvent event,
    Emitter<ContentState> emit,
  ) async {
    final currentState = (state is MyContentLoaded)
        ? (state as MyContentLoaded)
        : const MyContentLoaded();

    final result = await getContentTransactions(GetContentTransactionsParams(
      contentId: event.contentId,
      limit: event.limit,
      offset: event.offset,
      showLoader: false,
    ));
    result.fold(
      (failure) {
        debugPrint(
            "DEBUG: ContentBloc FetchContentTransactions failure: ${failure.message}");
        emit(currentState);
      },
      (transactions) => emit(ContentTransactionsLoaded(
        transactions,
        allContent: currentState.allContent,
        myContent: currentState.myContent,
        allPage: currentState.allPage,
        myPage: currentState.myPage,
        hasMoreAll: currentState.hasMoreAll,
        hasMoreMy: currentState.hasMoreMy,
        isLoadingAll: currentState.isLoadingAll,
        isLoadingMy: currentState.isLoadingMy,
      )),
    );
  }

  Future<void> _onRecordContentView(
    RecordContentViewEvent event,
    Emitter<ContentState> emit,
  ) async {
    // 1. Fire socket event immediately
    contentSocketDataSource.recordContentView(
      contentId: event.contentId,
      userId: event.userId,
    );

    // 2. Fallback to REST API
    await recordContentView(RecordContentViewParams(
      contentId: event.contentId,
      userId: event.userId,
    ));
  }

  Future<void> _onContentViewRecordedBroadcast(
    OnContentViewRecordedBroadcast event,
    Emitter<ContentState> emit,
  ) async {
    final data = event.data;
    final String? contentId = data['contentId']?.toString();
    final int? newViewCount = data['view_count'] is int
        ? data['view_count']
        : int.tryParse(data['view_count']?.toString() ?? '');

    if (contentId == null) return;

    final currentState = state;
    if (currentState is MyContentLoaded) {
      // Update the specific content item in the lists if it exists
      List<ContentItem> updatedAll = currentState.allContent.map((item) {
        if (item.id == contentId && newViewCount != null) {
          return item.copyWith(contentViewCount: newViewCount);
        }
        return item;
      }).toList();

      List<ContentItem> updatedMy = currentState.myContent.map((item) {
        if (item.id == contentId && newViewCount != null) {
          return item.copyWith(contentViewCount: newViewCount);
        }
        return item;
      }).toList();

      // If we are currently in ContentDetailLoaded, update that content as well
      if (currentState is ContentDetailLoaded) {
        ContentItem updatedDetail = currentState.content;
        if (updatedDetail.id == contentId && newViewCount != null) {
          updatedDetail =
              updatedDetail.copyWith(contentViewCount: newViewCount);
        }

        emit(ContentDetailLoaded(
          updatedDetail,
          allContent: updatedAll,
          myContent: updatedMy,
          allPage: currentState.allPage,
          myPage: currentState.myPage,
          hasMoreAll: currentState.hasMoreAll,
          hasMoreMy: currentState.hasMoreMy,
          isLoadingAll: currentState.isLoadingAll,
          isLoadingMy: currentState.isLoadingMy,
        ));
      } else {
        emit(currentState.copyWith(
          allContent: updatedAll,
          myContent: updatedMy,
        ));
      }
    }
  }
}
