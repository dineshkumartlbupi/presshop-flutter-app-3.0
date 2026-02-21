import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../domain/usecases/get_feeds.dart';
import '../../domain/usecases/toggle_feed_interaction.dart';
import 'feed_event.dart';
import 'feed_state.dart';
import '../../domain/entities/feed.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc({
    required this.getFeeds,
    required this.toggleFeedInteraction,
  }) : super(const FeedState()) {
    on<FetchFeeds>(_onFetchFeeds);
    on<LoadMoreFeeds>(_onLoadMoreFeeds);
    on<ToggleLikeFeed>(_onToggleLike);
    on<ToggleFavouriteFeed>(_onToggleFavourite);
    on<ToggleEmojiFeed>(_onToggleEmoji);
    on<ToggleClapFeed>(_onToggleClap);
  }
  final GetFeeds getFeeds;
  final ToggleFeedInteraction toggleFeedInteraction;

  Future<void> _onFetchFeeds(FetchFeeds event, Emitter<FeedState> emit) async {
    Map<String, dynamic> filters = Map.from(state.filters);

    if (event.newFilters != null) {
      filters.addAll(event.newFilters!);
    }

    // Reset if refresh
    int offset = 0;
    if (event.isRefresh) {
      offset = 0;
    } else {
      offset = int.tryParse(filters['offset'].toString()) ?? 0;
    }

    filters['offset'] = offset.toString();

    final cacheBox = Hive.box('sync_cache');
    final String cacheKey =
        'feeds_${filters['allcontent'] ?? 'all'}_${filters['alltask'] ?? 'all'}';

    if (offset == 0) {
      final cachedData = cacheBox.get(cacheKey);
      if (cachedData != null && cachedData is List) {
        try {
          final cachedFeeds = cachedData
              .map((e) => Feed(
                    id: (e['id'] ?? '').toString(),
                    heading: (e['heading'] ?? '').toString(),
                    description: (e['description'] ?? '').toString(),
                    location: (e['location'] ?? '').toString(),
                    categoryName: (e['category_name'] ?? '').toString(),
                    askPrice: (e['ask_price'] ?? '').toString(),
                    displayPrice: (e['display_price'] ?? '').toString(),
                    displayCurrency: (e['display_currency'] ?? '').toString(),
                    viewCount: (e['view_count'] ?? 0),
                    offerCount: (e['offer_count'] ?? 0),
                    createdAt: (e['created_at'] ?? '').toString(),
                    timeAgo: (e['time_ago'] ?? '').toString(),
                    feedImage: (e['feed_image'] ?? '').toString(),
                    status: (e['status'] ?? '').toString(),
                    isFavourite: e['is_favourite'] ?? false,
                    isLiked: e['is_liked'] ?? false,
                    isEmoji: e['is_emoji'] ?? false,
                    isClap: e['is_clap'] ?? false,
                    contentList: (e['content_list'] as List? ?? [])
                        .map((c) => FeedContent(
                              id: (c['id'] ?? '').toString(),
                              mediaType: (c['media_type'] ?? '').toString(),
                              mediaUrl: (c['media_url'] ?? '').toString(),
                              thumbnail: (c['thumbnail'] ?? '').toString(),
                            ))
                        .toList(),
                    type: (e['type'] ?? '').toString(),
                    isDraft: e['is_draft'] ?? false,
                    userId: (e['user_id'] ?? '').toString(),
                    saleStatus: (e['sale_status'] ?? '').toString(),
                    paidStatus: (e['paid_status'] ?? '').toString(),
                  ))
              .toList();

          if (cachedFeeds.isNotEmpty) {
            emit(state.copyWith(
              status: FeedStatus.success,
              feeds: cachedFeeds,
              filters: filters,
            ));
          }
        } catch (e) {
          debugPrint("Error loading feeds from cache: $e");
        }
      }
    }

    // 2. Set loading if no cached data or not success yet
    if (state.status != FeedStatus.success ||
        (offset == 0 && state.feeds.isEmpty)) {
      emit(state.copyWith(status: FeedStatus.loading, filters: filters));
    }

    // 3. Fetch fresh data
    final result = await getFeeds(GetFeedsParams(params: filters));

    result.fold(
      (failure) {
        if (state.feeds.isEmpty) {
          emit(state.copyWith(
              status: FeedStatus.failure, errorMessage: failure.toString()));
        }
      },
      (feeds) {
        // Sort by createdAt descending (newest first)
        final sortedFeeds = List<Feed>.from(feeds)
          ..sort((a, b) {
            final dateA = DateTime.tryParse(a.createdAt) ?? DateTime(0);
            final dateB = DateTime.tryParse(b.createdAt) ?? DateTime(0);
            return dateB.compareTo(dateA);
          });

        if (offset == 0) {
          cacheBox.put(cacheKey, sortedFeeds.map((e) => e.toJson()).toList());
        }

        emit(state.copyWith(
          status: FeedStatus.success,
          feeds: offset == 0 ? sortedFeeds : [...state.feeds, ...sortedFeeds],
          hasReachedMax: feeds.isEmpty ||
              feeds.length < (int.tryParse(filters['limit'] ?? "10") ?? 10),
          filters: filters,
        ));
      },
    );
  }

  Future<void> _onLoadMoreFeeds(
      LoadMoreFeeds event, Emitter<FeedState> emit) async {
    if (state.hasReachedMax) return;

    Map<String, dynamic> filters = Map.from(state.filters);
    int currentOffset = int.tryParse(filters['offset'].toString()) ?? 0;
    int limit = int.tryParse(filters['limit'].toString()) ?? 10;
    int newOffset = currentOffset + limit;

    filters['offset'] = newOffset.toString();

    final result = await getFeeds(GetFeedsParams(params: filters));

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.toString())),
      (newFeeds) {
        // Sort by createdAt descending (newest first)
        final sortedNewFeeds = List<Feed>.from(newFeeds)
          ..sort((a, b) {
            final dateA = DateTime.tryParse(a.createdAt) ?? DateTime(0);
            final dateB = DateTime.tryParse(b.createdAt) ?? DateTime(0);
            return dateB.compareTo(dateA);
          });

        emit(state.copyWith(
          status: FeedStatus.success,
          feeds: List.of(state.feeds)..addAll(sortedNewFeeds),
          hasReachedMax: newFeeds.isEmpty || newFeeds.length < limit,
          filters: filters,
        ));
      },
    );
  }

  Future<void> _onToggleLike(
      ToggleLikeFeed event, Emitter<FeedState> emit) async {
    await _toggleInteraction(event.id, emit, isLike: event.isLiked);
  }

  Future<void> _onToggleFavourite(
      ToggleFavouriteFeed event, Emitter<FeedState> emit) async {
    await _toggleInteraction(event.id, emit, isFav: event.isFavourite);
  }

  Future<void> _onToggleEmoji(
      ToggleEmojiFeed event, Emitter<FeedState> emit) async {
    await _toggleInteraction(event.id, emit, isEmoji: event.isEmoji);
  }

  Future<void> _onToggleClap(
      ToggleClapFeed event, Emitter<FeedState> emit) async {
    await _toggleInteraction(event.id, emit, isClap: event.isClap);
  }

  Future<void> _toggleInteraction(String id, Emitter<FeedState> emit,
      {bool? isLike, bool? isFav, bool? isEmoji, bool? isClap}) async {
    // Find the feed item
    int index = state.feeds.indexWhere((f) => f.id == id);
    if (index == -1) return;

    Feed currentFeed = state.feeds[index];

    bool newLike = isLike ?? currentFeed.isLiked;
    bool newFav = isFav ?? currentFeed.isFavourite;
    bool newEmoji = isEmoji ?? currentFeed.isEmoji;
    bool newClap = isClap ?? currentFeed.isClap;

    if (isFav == true) {
      newLike = false;
      newEmoji = false;
      newClap = false;
    }
    if (isLike == true) {
      newFav = false;
      newEmoji = false;
      newClap = false;
    }
    if (isEmoji == true) {
      newFav = false;
      newLike = false;
      newClap = false;
    }
    if (isClap == true) {
      newFav = false;
      newLike = false;
      newEmoji = false;
    }

    // Update List
    List<Feed> updatedFeeds = List.from(state.feeds);
    updatedFeeds[index] = currentFeed.copyWith(
      isFavourite: newFav,
      isLiked: newLike,
      isEmoji: newEmoji,
      isClap: newClap,
    );

    emit(state.copyWith(feeds: updatedFeeds));

    final result = await toggleFeedInteraction(ToggleFeedInteractionParams(
      id: id,
      isLike: newLike,
      isFav: newFav,
      isEmoji: newEmoji,
      isClap: newClap,
    ));

    result.fold((failure) {
      List<Feed> revertedFeeds = List.from(state.feeds);
      revertedFeeds[index] = currentFeed;
      emit(state.copyWith(
          feeds: revertedFeeds, errorMessage: "Interaction failed"));
    }, (success) {});
  }
}
