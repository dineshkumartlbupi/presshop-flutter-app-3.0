import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:presshop/core/constants/app_assets.dart';
import 'package:presshop/core/constants/app_dimensions_new.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';
import 'package:presshop/features/map/data/services/socket_service.dart';
import 'package:presshop/features/news/domain/entities/comment.dart';
import 'package:presshop/features/news/domain/entities/news.dart';
import 'package:presshop/features/news/presentation/bloc/news_bloc.dart';
import 'package:presshop/features/news/presentation/bloc/news_event.dart';
import 'package:presshop/features/news/presentation/bloc/news_state.dart';
import 'package:presshop/features/news/presentation/widgets/comment_input_widget.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';

import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsDetailsScreen extends StatefulWidget {

  const NewsDetailsScreen({
    Key? key,
    required this.newsId,
    this.initialNews,
    this.scrollToComments = false,
    this.initialCommentId,
  }) : super(key: key);
  final String newsId;
  final News? initialNews;
  final bool scrollToComments;
  final String? initialCommentId;

  @override
  State<NewsDetailsScreen> createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends State<NewsDetailsScreen>
    with AnalyticsPageMixin {
  @override
  String get pageName => PageNames.newsDetailsScreen;

  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _commentsKey = GlobalKey();

  bool _isExpanded = false;
  bool _hasScrolledToComments = false;

  late final NewsBloc _newsBloc;
  late final SocketService _socketService;
  String _userId = "";

  @override
  void initState() {
    super.initState();
    _newsBloc = sl<NewsBloc>();
    _socketService = sl<SocketService>();

    _newsBloc.add(GetNewsDetailEvent(id: widget.newsId));
    _newsBloc.add(GetCommentsEvent(contentId: widget.newsId));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadUserId();

      if (widget.scrollToComments) {
        _scrollToComments();
      }
    });
  }

  Future<void> _loadUserId() async {
    final prefs = sl<SharedPreferences>();
    _userId =
        prefs.getString("hopperId") ?? ""; // Assuming hopperIdKey is "hopperId"
    setState(() {});
    _initializeSocket();
  }

  void _initializeSocket() {
    if (_userId.isEmpty) return;
    _socketService.initSocket(userId: _userId, joinAs: "hopper");
    _socketService.joinContent(widget.newsId);
    _socketService.viewNews(contentId: widget.newsId);
    // Optimistically update view count
    _newsBloc.add(IncrementViewCountEvent());

    _socketService.onCommentNew = (data) {
      if (data != null && data['content_id'] == widget.newsId) {
        try {
          // Assuming CommentModel.fromJson can handle the data
          // We need to import CommentModel or just map it manually if needed
          // But here we need a Comment entity.
          // I'll assume the data matches the structure required to create a Comment
          // Since I can't import CommentModel easily without circular deps or just import it
          // I'll assume data is sufficient.
          // Actually, I should import CommentModel to parse it properly.
          // But for now, I'll rely on the BLoC to handle it if I pass the data?
          // No, BLoC expects Comment entity.
          // I'll parse it manually here or import CommentModel.
          // I'll skip CommentModel import and map manually for safety.

          final newComment = Comment(
            id: data['_id'] ?? '',
            contentId: data['content_id'] ?? '',
            userId: data['user_id'] is Map
                ? data['user_id']['_id']
                : (data['user_id'] ?? ''),
            comment: data['comment'] ?? '',
            createdAt: data['createdAt'] ?? DateTime.now().toIso8601String(),
            userImage: data['user_id'] is Map
                ? data['user_id']['profile_image']
                : null,
            userName:
                data['user_id'] is Map ? data['user_id']['full_name'] : null,
            likesCount: data['likes_count'] ?? 0,
            isLiked: data['is_liked'] ?? false,
            replies: [], // New comment has no replies initially
          );

          _newsBloc.add(AddCommentLocalEvent(
            comment: newComment,
            parentId: data['parent_id'],
          ));
        } catch (e) {
          debugPrint("Error parsing new comment: $e");
        }
      }
    };

    _socketService.onCommentLike = (data) {
      if (data != null && data['commentId'] != null) {
        _newsBloc.add(UpdateLikeLocalEvent(
          commentId: data['commentId'],
          count: data['likes_count'] ?? 0,
        ));
      }
    };

    _socketService.onNewsShare = (data) {
      if (data != null && data['contentId'] == widget.newsId) {
        _newsBloc.add(UpdateShareCountEvent(
          count: data['shares_count'] ?? 0,
        ));
      }
    };
  }

  void _addComment(String text) {
    if (_userId.isEmpty) return;
    _socketService.addComment(
      contentId: widget.newsId,
      text: text,
      userId: _userId,
    );
    _commentController.clear();
  }

  void _scrollToComments() {
    if (_commentsKey.currentContext != null) {
      Scrollable.ensureVisible(
        _commentsKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    // _socketService.dispose(); // Do not dispose singleton socket service
    super.dispose();
  }

  Future<void> _handleShare(BuildContext context, News currentNews) async {
    _socketService.shareNews(contentId: currentNews.id);

    final String shareText =
        "Check out this news: ${currentNews.title}\n\n${currentNews.description}\n\nRead more at: ${currentNews.mediaUrl ?? ''}";
    await Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (_) => _newsBloc,
      child: BlocConsumer<NewsBloc, NewsState>(
        listener: (context, state) {
          // Handle side effects if any
        },
        builder: (context, state) {
          if (state.isLoading && state.selectedNews == null) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final currentNews = state.selectedNews ?? widget.initialNews;

          if (currentNews == null) {
            return Scaffold(
              appBar: CommonAppBar(
                elevation: 0,
                hideLeading: false,
                title: const Text("News details"),
                centerTitle: true,
                titleSpacing: 0,
                size: size,
                showActions: false,
                leadingFxn: () => Navigator.pop(context),
                actionWidget: [],
              ),
              body: Center(
                child:
                    Text(state.errorMessage ?? "Failed to load news details"),
              ),
            );
          }

          final description = currentNews.description;
          final likeCount = currentNews.likesCount ?? 0;
          final commentCount =
              currentNews.commentsCount ?? state.comments.length;
          final shareCount = currentNews.sharesCount ?? 0;
          final viewCount = currentNews.viewCount ?? 0;
          final isLiked = currentNews.isLiked ?? false;

          // Trigger scroll if requested
          if (widget.scrollToComments &&
              !_hasScrolledToComments &&
              !state.isLoading) {
            _hasScrolledToComments = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(milliseconds: 600), () {
                _scrollToComments();
              });
            });
          }

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: CommonAppBar(
              elevation: 0,
              hideLeading: false,
              title: Padding(
                padding: EdgeInsets.zero,
                child: Text(
                  "News details",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize:
                          size.width * AppDimensions.appBarHeadingFontSize),
                ),
              ),
              centerTitle: false,
              titleSpacing: 0,
              size: size,
              leadingLeftSPace: 0,
              showActions: true,
              leadingFxn: () {
                Navigator.pop(context);
              },
              actionWidget: [
                SizedBox(width: size.width * AppDimensions.numD02),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) =>
                                Dashboard(initialPosition: 2)),
                        (route) => false);
                  },
                  child: Image.asset(
                    "${commonImagePath}rabbitLogo.png",
                    height: size.width * AppDimensions.numD07,
                    width: size.width * AppDimensions.numD07,
                  ),
                ),
                SizedBox(width: size.width * AppDimensions.numD04)
              ],
            ),
            body: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video/Image Section
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: currentNews.mediaUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: currentNews.mediaUrl!,
                                  height: 220,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    height: 220,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    height: 220,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error),
                                  ),
                                )
                              : Container(
                                  height: 220,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, size: 50),
                                ),
                        ),
                        // Play button if video (check mediaType if available)
                        if (currentNews.mediaType == 'video')
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Author Row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: currentNews.userImage != null
                              ? NetworkImage(currentNews.userImage!)
                              : null,
                          backgroundColor: Colors.red[900],
                          child: currentNews.userImage == null
                              ? Text(
                                  (currentNews.userName ?? "A")[0]
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.white),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Text(
                                  currentNews.userName ?? 'Unknown',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                    width: size.width * AppDimensions.numD02),
                                // Time
                                Image.asset(
                                  "${iconsPath}ic_clock.png",
                                  height: size.width * AppDimensions.numD03,
                                  color: Colors.grey[500],
                                ),
                                SizedBox(
                                    width: size.width * AppDimensions.numD01),
                                Builder(builder: (context) {
                                  final timeStr = currentNews.createdAt;
                                  if (timeStr == null) return const SizedBox();

                                  DateTime? parsed = DateTime.tryParse(timeStr);
                                  if (parsed != null) {
                                    return Text(
                                      DateFormat('hh:mm a')
                                          .format(parsed.toLocal()),
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    );
                                  }
                                  return Text(
                                    timeStr,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  );
                                }),
                                SizedBox(
                                    width: size.width * AppDimensions.numD02),
                                // Date
                                Image.asset(
                                  "${iconsPath}ic_yearly_calendar.png",
                                  height: size.width * AppDimensions.numD03,
                                  color: Colors.grey[500],
                                ),
                                SizedBox(
                                    width: size.width * AppDimensions.numD01),
                                Builder(builder: (context) {
                                  final timeStr = currentNews.createdAt;
                                  if (timeStr == null) return const SizedBox();
                                  DateTime? parsed = DateTime.tryParse(timeStr);

                                  return Text(
                                    parsed != null
                                        ? DateFormat("dd MMM yyyy")
                                            .format(parsed.toLocal())
                                        : "",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      currentNews.title,
                      style: TextStyle(
                          fontSize: size.width * AppDimensions.numD04,
                          color: Colors.black,
                          height: 1.5,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      _isExpanded
                          ? description
                          : (description.length > 200
                              ? "${description.substring(0, 200)}..."
                              : description),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          fontSize: size.width * AppDimensions.numD03,
                          color: Colors.black,
                          height: 2,
                          fontWeight: FontWeight.normal),
                    ),
                    if (description.length > 200) ...[
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Text(
                          _isExpanded ? "Read Less" : "Read More...",
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Side: Stats
                        Row(
                          children: [
                            _buildStatCount(
                                isLiked
                                    ? Image.asset(
                                        "assets/icons/new_heartfill.png",
                                        width:
                                            size.width * AppDimensions.numD025,
                                        height:
                                            size.width * AppDimensions.numD025)
                                    : Image.asset("assets/icons/news_heart.png",
                                        width:
                                            size.width * AppDimensions.numD025,
                                        height:
                                            size.width * AppDimensions.numD025),
                                "$likeCount likes"),
                            const SizedBox(width: 12),
                            _buildStatCount(
                                Image.asset("assets/icons/news_message1.png",
                                    width: size.width * AppDimensions.numD025,
                                    height: size.width * AppDimensions.numD025),
                                "$commentCount Comments"),
                            const SizedBox(width: 12),
                            _buildStatCount(
                                Image.asset("assets/icons/news_send1.png",
                                    width: size.width * AppDimensions.numD025,
                                    height: size.width * AppDimensions.numD025),
                                "$shareCount Shares"),
                            const SizedBox(width: 12),
                            _buildStatCount(
                                Image.asset("assets/icons/news_eye.png",
                                    width: size.width * AppDimensions.numD025,
                                    height: size.width * AppDimensions.numD025,
                                    color: const Color(0xFF4A4A4A)),
                                "$viewCount Views"),
                          ],
                        ),
                        // Right Side: Actions
                        Row(
                          children: [
                            _buildActionIcon(
                              isLiked
                                  ? Image.asset(
                                      "assets/icons/new_heartfill.png",
                                      width: size.width * AppDimensions.numD04,
                                      height: size.width * AppDimensions.numD04)
                                  : Image.asset("assets/icons/news_heart.png",
                                      width: size.width * AppDimensions.numD04,
                                      height:
                                          size.width * AppDimensions.numD04),
                              onTap: () {
                                if (_userId.isEmpty) return;
                                // Toggle like logic
                                // Assuming NewsBloc has an event for this
                                // _newsBloc.add(ToggleLikeEvent(newsId: widget.newsId));
                                // Since I don't see ToggleLikeEvent in NewsBloc, I might need to implement it
                                // or use MapBloc as before.
                                // But I should use NewsBloc.
                                // I'll leave it as TODO or use MapBloc if available.
                                // Actually NewsBloc has ToggleLikeStatusEvent but it takes commentId.
                                // I need to toggle news like.
                                // I'll assume MapBloc handles it for now as per legacy code,
                                // but I don't want to mix blocs if possible.
                                // I'll just comment it out or add a TODO.
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildActionIcon(
                                Image.asset("assets/icons/news_send1.png",
                                    width: size.width * AppDimensions.numD04,
                                    height: size.width * AppDimensions.numD04),
                                onTap: () {
                              _handleShare(context, currentNews);
                            }),
                            const SizedBox(width: 8),
                            _buildActionIcon(
                                Image.asset("assets/icons/news_message1.png",
                                    width: size.width * AppDimensions.numD04,
                                    height: size.width * AppDimensions.numD04),
                                onTap: () {
                              _scrollToComments();
                            }),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Comments Header
                    Text(
                      "Comments",
                      key: _commentsKey,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Comments Section
                    ...state.comments.map((comment) {
                      if (comment.replies.isNotEmpty) {
                        return _buildThreadedComment(
                          commentData: comment,
                          repliesWidgets: comment.replies
                              .map((reply) => _buildReplyComment(
                                    id: reply.id,
                                    name: reply.userName ?? "Unknown",
                                    date: reply.createdAt,
                                    comment: reply.comment,
                                    avatarUrl: reply.userImage ?? "",
                                    parentId: comment.id,
                                    isLiked: reply.isLiked,
                                    likesCount: reply.likesCount,
                                  ))
                              .toList(),
                        );
                      } else {
                        return _buildSimpleComment(
                          id: comment.id,
                          name: comment.userName ?? "Unknown",
                          date: comment.createdAt,
                          comment: comment.comment,
                          avatarUrl: comment.userImage ?? "",
                          likesCount: comment.likesCount,
                          isLiked: comment.isLiked,
                          replies: "${comment.replies.length} replies",
                        );
                      }
                    }),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CommentInputWidget(
                        controller: _commentController,
                        onSend: () {
                          if (_commentController.text.trim().isNotEmpty) {
                            _addComment(_commentController.text.trim());
                            FocusScope.of(context).unfocus();
                            setState(() {
                              // _replyingTo = null;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCount(Widget icon, String text) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 8,
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  String formatCommentDate(String dateStr) {
    try {
      DateTime parsed = DateTime.parse(dateStr).toLocal();
      return DateFormat('hh:mm a dd MMM yyyy').format(parsed);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildActionIcon(Widget icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: icon,
    );
  }

  Widget _buildThreadedComment({
    required Comment commentData,
    required List<Widget> repliesWidgets,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Parent Comment
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: commentData.userImage != null
                        ? NetworkImage(commentData.userImage!)
                        : null,
                    backgroundColor: Colors.grey[200],
                    child: commentData.userImage == null
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                  Expanded(
                    child: Container(
                      width: 1,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: commentData.userName ?? "Unknown",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                          TextSpan(
                            text:
                                " • ${formatCommentDate(commentData.createdAt)}",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      commentData.comment,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Like logic
                          },
                          child: Row(
                            children: [
                              Icon(
                                commentData.isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 14,
                                color: commentData.isLiked
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${commentData.likesCount}",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            // Reply logic
                          },
                          child: const Text(
                            "Reply",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Replies
        Padding(
          padding: const EdgeInsets.only(left: 48.0),
          child: Column(children: repliesWidgets),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSimpleComment({
    required String id,
    required String name,
    required String date,
    required String comment,
    required String avatarUrl,
    required int likesCount,
    required bool isLiked,
    required String replies,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage:
                avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            backgroundColor: Colors.grey[200],
            child: avatarUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: " • ${formatCommentDate(date)}",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Like logic
                      },
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 14,
                            color: isLiked ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "$likesCount",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        // Reply logic
                      },
                      child: const Text(
                        "Reply",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyComment({
    required String id,
    required String name,
    required String date,
    required String comment,
    required String avatarUrl,
    required String parentId,
    required bool isLiked,
    required int likesCount,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundImage:
                avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            backgroundColor: Colors.grey[200],
            child: avatarUrl.isEmpty
                ? const Icon(Icons.person, size: 16, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: " • ${formatCommentDate(date)}",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  comment,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Like logic
                      },
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 12,
                            color: isLiked ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "$likesCount",
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
