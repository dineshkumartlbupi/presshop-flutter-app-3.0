import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_feeds.dart';
import '../../domain/usecases/toggle_feed_interaction.dart';
import 'feed_event.dart';
import 'feed_state.dart';
import '../../domain/entities/feed.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetFeeds getFeeds;
  final ToggleFeedInteraction toggleFeedInteraction;

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

  Future<void> _onFetchFeeds(FetchFeeds event, Emitter<FeedState> emit) async {
    Map<String, dynamic> filters = Map.from(state.filters); // Copy existing

    if (event.newFilters != null) {
      filters.addAll(event.newFilters!);
    }
    
    // Reset if refresh
    int offset = 0;
    if (event.isRefresh) {
       offset = 0;
       emit(state.copyWith(status: FeedStatus.loading, feeds: [])); // Clear or keep? Better to keep if pull to refresh?
    } else {
       offset = int.tryParse(filters['offset'].toString()) ?? 0;
    }
    
    filters['offset'] = offset.toString();

    // If loading initial state or refresh
    emit(state.copyWith(status: FeedStatus.loading, filters: filters));

    final result = await getFeeds(GetFeedsParams(params: filters));
    
    result.fold(
      (failure) => emit(state.copyWith(status: FeedStatus.failure, errorMessage: failure.toString())),
      (feeds) => emit(state.copyWith(
        status: FeedStatus.success,
        feeds: feeds,
        hasReachedMax: feeds.isEmpty || feeds.length < (int.tryParse(filters['limit'] ?? "10") ?? 10),
      )),
    );
  }

  Future<void> _onLoadMoreFeeds(LoadMoreFeeds event, Emitter<FeedState> emit) async {
    if (state.hasReachedMax) return;
    
    Map<String, dynamic> filters = Map.from(state.filters);
    int currentOffset = int.tryParse(filters['offset'].toString()) ?? 0;
    int limit = int.tryParse(filters['limit'].toString()) ?? 10;
    int newOffset = currentOffset + limit;
    
    filters['offset'] = newOffset.toString();
    
    // Do not set status to loading to avoid full screen loader, maybe use different status or UI handles it
    
    final result = await getFeeds(GetFeedsParams(params: filters));
    
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.toString())), // Maybe show snackbar?
      (newFeeds) {
         emit(state.copyWith(
           status: FeedStatus.success,
           feeds: List.of(state.feeds)..addAll(newFeeds),
           hasReachedMax: newFeeds.isEmpty || newFeeds.length < limit,
           filters: filters, // Update offset in state
         ));
      },
    );
  }
  
  // Interaction Logic:
  // When interacting, we optimistically update the UI in State, then call API. 
  // If API fails, we revert.
  
  Future<void> _onToggleLike(ToggleLikeFeed event, Emitter<FeedState> emit) async {
      await _toggleInteraction(event.id, emit, isLike: event.isLiked);
  }
  
  Future<void> _onToggleFavourite(ToggleFavouriteFeed event, Emitter<FeedState> emit) async {
      await _toggleInteraction(event.id, emit, isFav: event.isFavourite);
  }
  
  Future<void> _onToggleEmoji(ToggleEmojiFeed event, Emitter<FeedState> emit) async {
      await _toggleInteraction(event.id, emit, isEmoji: event.isEmoji);
  }
  
  Future<void> _onToggleClap(ToggleClapFeed event, Emitter<FeedState> emit) async {
      await _toggleInteraction(event.id, emit, isClap: event.isClap);
  }
  
  Future<void> _toggleInteraction(String id, Emitter<FeedState> emit, {bool? isLike, bool? isFav, bool? isEmoji, bool? isClap}) async {
      // Find the feed item
      int index = state.feeds.indexWhere((f) => f.id == id);
      if (index == -1) return;
      
      Feed currentFeed = state.feeds[index];
      
      // Calculate new state
      bool newLike = isLike ?? currentFeed.isLiked;
      bool newFav = isFav ?? currentFeed.isFavourite;
      bool newEmoji = isEmoji ?? currentFeed.isEmoji;
      bool newClap = isClap ?? currentFeed.isClap;
      
      // Logic from `FeedScreen`: If one is true, others might need reset?
      // `FeedScreen` logic:
      // if (isFav) { isLike=false; isEmoji=false; isClap=false; }
      // if (isLiked) { isFav=false; isEmoji=false; isClap=false; }
      // ... mutually exclusive?
      // Let's re-read `FeedScreen` logic carefully.
      /*
         if (feedDataList[index].isFavourite) {
             feedDataList[index].isLiked = false;
             feedDataList[index].isEmoji = false;
             feedDataList[index].isClap = false;
         }
      */
      // Yes, it seems they are mutually exclusive.
      
      if (isFav == true) { newLike=false; newEmoji=false; newClap=false; }
      if (isLike == true) { newFav=false; newEmoji=false; newClap=false; }
      if (isEmoji == true) { newFav=false; newLike=false; newClap=false; }
      if (isClap == true) { newFav=false; newLike=false; newEmoji=false; }
      
      // Update List
      List<Feed> updatedFeeds = List.from(state.feeds);
      // We need `Feed` entity to have `copyWith`. 
      // I didn't add `copyWith` to entity. I should have. 
      // I'll create a new Feed instance manually for now or add copyWith to entity.
      // Manually for speed now.
      
      updatedFeeds[index] = Feed(
          id: currentFeed.id,
          heading: currentFeed.heading,
          description: currentFeed.description,
          location: currentFeed.location,
          categoryName: currentFeed.categoryName,
          askPrice: currentFeed.askPrice,
          displayPrice: currentFeed.displayPrice,
          displayCurrency: currentFeed.displayCurrency,
          viewCount: currentFeed.viewCount,
          offerCount: currentFeed.offerCount,
          createdAt: currentFeed.createdAt,
          timeAgo: currentFeed.timeAgo,
          feedImage: currentFeed.feedImage,
          status: currentFeed.status,
          isFavourite: newFav, 
          isLiked: newLike,
          isEmoji: newEmoji,
          isClap: newClap,
          contentList: currentFeed.contentList,
          type: currentFeed.type,
          isDraft: currentFeed.isDraft,
          userId: currentFeed.userId,
          saleStatus: currentFeed.saleStatus, 
          paidStatus: currentFeed.paidStatus,
      );
      
      emit(state.copyWith(feeds: updatedFeeds)); // Optimistic update
      
      final result = await toggleFeedInteraction(ToggleFeedInteractionParams(
          id: id,
          isLike: newLike,
          isFav: newFav,
          isEmoji: newEmoji,
          isClap: newClap,
      ));
      
      result.fold(
          (failure) {
              // Revert if failed
              List<Feed> revertedFeeds = List.from(state.feeds);
               revertedFeeds[index] = currentFeed;
               emit(state.copyWith(feeds: revertedFeeds, errorMessage: "Interaction failed"));
          },
          (success) {
              // Success, do nothing as optimistic update is already there.
          }
      );
  }
}
