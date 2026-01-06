import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/view/dashboard/Dashboard.dart';
import 'package:presshop/view/map_and_news/controller/news_controller.dart';
import 'package:presshop/view/map_and_news/controller/map_controller.dart';
import 'package:presshop/view/map_and_news/models/marker_model.dart';
import 'package:presshop/view/map_and_news/widgets/comment_input_widget.dart';
import 'package:presshop/view/map_and_news/services/socket_service.dart';
import 'package:presshop/view/map_and_news/models/comment_data.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/main.dart';

import 'package:presshop/utils/ShareHelper.dart';
import 'package:intl/intl.dart';

class NewsDetailsScreen extends ConsumerStatefulWidget {
  final String newsId;
  final Incident? initialIncident;
  final bool scrollToComments;
  final String? initialCommentId;

  const NewsDetailsScreen({
    Key? key,
    required this.newsId,
    this.initialIncident,
    this.scrollToComments = false,
    this.initialCommentId,
  }) : super(key: key);

  @override
  ConsumerState<NewsDetailsScreen> createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends ConsumerState<NewsDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _commentsKey = GlobalKey();

  bool _isExpanded = false;
  bool _isLiked = false;
  bool _hasScrolledToComments = false;

  String? _replyingTo;
  final Map<String, GlobalKey> _inputKeys = {};
  final Map<String, GlobalKey> _commentKeys = {};
  final Map<String, GlobalKey> _replyAnchors = {};

  late final SocketService _socketService;
  String _userId = "";

  @override
  void initState() {
    super.initState();
    _socketService = SocketService();
    // Socket initialization is handled in _loadUserId logic or we can call it here if we had userId.
    // We wait for _loadUserId to initialize socket properly.

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(newsDetailsControllerProvider)
          .fetchNewsDetails(widget.newsId);

      // Load user ID and initialize socket after fetching news details
      await _loadUserId();

      if (widget.scrollToComments) {
        _scrollToComments();
      }

      if (widget.initialCommentId != null) {
        // Give a bit more time for comments to render
        Future.delayed(const Duration(milliseconds: 1500), () {
          _scrollToComment(widget.initialCommentId!);
        });
      }
    });
  }

  void _scrollToComment(String commentId) {
    if (!mounted) return;

    final key = _commentKeys[commentId];
    if (key?.currentContext != null) {
      debugPrint("Scrolling to comment: $commentId");
      Scrollable.ensureVisible(key!.currentContext!,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          alignment: 0.5);
    } else {
      debugPrint("Comment key not found/context null for: $commentId");
    }
  }

  Future<void> _loadUserId() async {
    _userId = sharedPreferences?.getString(hopperIdKey) ?? "";
    setState(() {});
    _initializeSocket();
  }

  void _initializeSocket() {
    if (_userId.isEmpty) return;
    _socketService.initSocket(userId: _userId, joinAs: "hopper");
    _socketService.joinContent(widget.newsId);
    _socketService.viewNews(contentId: widget.newsId);
    // Optimistically update view count
    ref.read(newsDetailsControllerProvider).incrementViewCount();

    _socketService.onCommentNew = (data) {
      if (data != null && data['content_id'] == widget.newsId) {
        // Parse and add to list (handle parent_id)
        try {
          CommentData newComment = CommentData.fromJson(data);
          if (data['parent_id'] != null) {
            ref
                .read(newsDetailsControllerProvider)
                .addCommentLocal(newComment, parentId: data['parent_id']);
          } else {
            ref.read(newsDetailsControllerProvider).addCommentLocal(newComment);
          }
        } catch (e) {
          debugPrint("Error parsing new comment: $e");
        }
      }
    };

    _socketService.onCommentLike = (data) {
      // Update like count locally
      if (data != null && data['commentId'] != null) {
        ref
            .read(newsDetailsControllerProvider)
            .updateLikeLocal(data['commentId'], data['likes_count'] ?? 0);
      }
    };

    _socketService.onNewsLike = (data) {
      // Update news like count locally if needed
    };

    _socketService.onNewsShare = (data) {
      if (data != null && data['contentId'] == widget.newsId) {
        ref
            .read(newsDetailsControllerProvider)
            .updateShareCount(data['shares_count'] ?? 0);
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

    setState(() {
      _commentController.clear();
    });
  }

  void _addReply(String parentId, String text) {
    if (_userId.isEmpty) return;
    _socketService.addComment(
        contentId: widget.newsId,
        text: text,
        userId: _userId,
        parentId: parentId);
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
    _replyController.dispose();
    _scrollController.dispose();
    _socketService.dispose();
    super.dispose();
  }

  int get _totalCommentCount {
    final comments = ref.read(newsDetailsControllerProvider).comments;
    int count = comments.length;
    for (var c in comments) {
      count += c.replies.length;
    }
    return count;
  }

  Future<void> _handleShare(BuildContext context, Incident currentIncident,
      {String? commentId}) async {
    _socketService.shareNews(
        contentId: currentIncident.id); // Track share event

    await ShareHelper.handleShare(
      context: context,
      newsId: currentIncident.id,
      title: currentIncident.title ?? "News Update",
      imageUrl: currentIncident.image,
      commentId: commentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(newsDetailsControllerProvider, (previous, next) {
      if (previous?.incident == null && next.incident != null) {
        setState(() {
          _isLiked = next.incident?.isLiked ?? false;
        });
      }
    });

    final controller = ref.watch(newsDetailsControllerProvider);
    final currentIncident = controller.incident;

    final size = MediaQuery.of(context).size;

    if (controller.isLoading) {
      return Scaffold(
        body: Center(child: showAnimatedLoader(size)),
      );
    }

    if (currentIncident == null) {
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
          child: Text(controller.error ?? "Failed to load news details"),
        ),
      );
    }

    final description = currentIncident.description ?? "";

    // Stats from API or fallback
    // Stats from API or fallback
    final likeCount = currentIncident.likesCount ?? 0;
    final commentCount = currentIncident.commentsCount ?? _totalCommentCount;
    final shareCount = currentIncident.sharesCount ?? 0;
    final viewCount = currentIncident.viewCount ?? 0;

    // Trigger scroll if requested and data is loaded
    if (widget.scrollToComments && !_hasScrolledToComments) {
      _hasScrolledToComments = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // slight delay to let images/layout settle
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
          padding: EdgeInsets.only(left: false ? size.width * numD04 : 0),
          child: Text(
            "News details",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: size.width * appBarHeadingFontSize),
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
          SizedBox(
            width: size.width * numD02,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => Dashboard(initialPosition: 2)),
                  (route) => false);
            },
            child: Image.asset(
              "${commonImagePath}rabbitLogo.png",
              height: size.width * numD07,
              width: size.width * numD07,
            ),
          ),
          SizedBox(
            width: size.width * numD04,
          )
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
                    child: currentIncident.image != null
                        ? CachedNetworkImage(
                            imageUrl: currentIncident.image!,
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
                            errorWidget: (context, url, error) => Container(
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
                    backgroundColor: Colors.red[900],
                    child: const Text("J", style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            currentIncident.author ?? 'Jamuna TV',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: size.width * numD02),
                          // Time
                          Image.asset(
                            "${iconsPath}ic_clock.png",
                            height: size.width * numD03,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: size.width * numD01),
                          Builder(builder: (context) {
                            final timeStr = currentIncident.time;
                            if (timeStr == null) return const SizedBox();

                            // Try parsing as ISO first (createdAt)
                            DateTime? parsed = DateTime.tryParse(timeStr);
                            if (parsed != null) {
                              return Text(
                                DateFormat('hh:mm a').format(parsed),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              );
                            }

                            // Fallback
                            String displayTime = timeStr;
                            try {
                              displayTime = DateFormat('hh:mm a')
                                  .format(DateFormat("HH:mm").parse(timeStr));
                            } catch (_) {}

                            return Text(
                              displayTime,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            );
                          }),
                          SizedBox(width: size.width * numD02),
                          // Date
                          Image.asset(
                            "${iconsPath}ic_yearly_calendar.png",
                            height: size.width * numD03,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: size.width * numD01),
                          Builder(builder: (context) {
                            DateTime? parsedDate;
                            if (currentIncident.date != null) {
                              parsedDate =
                                  DateTime.tryParse(currentIncident.date!);
                            }
                            if (parsedDate == null &&
                                currentIncident.time != null) {
                              parsedDate =
                                  DateTime.tryParse(currentIncident.time!);
                            }

                            return Text(
                              parsedDate != null
                                  ? DateFormat("dd MMM yyyy").format(parsedDate)
                                  : (currentIncident.date ?? ""),
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
                currentIncident.title ??
                    "Car accident near Oxford Street causes heavy traffic delays today.",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD04,
                    color: Colors.black,
                    lineHeight: 1.5,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                _isExpanded
                    ? description
                    : (description.length > 20000
                        ? "${description.substring(0, 20000)}..."
                        : description),
                textAlign: TextAlign.justify,
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD03,
                    color: Colors.black,
                    lineHeight: 2,
                    fontWeight: FontWeight.normal),
              ),
              if (description.length > 20000) ...[
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
                          _isLiked
                              ? Image.asset("assets/icons/new_heartfill.png",
                                  width: size.width * numD025,
                                  height: size.width * numD025)
                              : Image.asset("assets/icons/news_heart.png",
                                  width: size.width * numD025,
                                  height: size.width * numD025),
                          "$likeCount likes"),
                      const SizedBox(width: 12),
                      _buildStatCount(
                          Image.asset("assets/icons/news_message1.png",
                              width: size.width * numD025,
                              height: size.width * numD025),
                          "$commentCount Comments"),
                      const SizedBox(width: 12),
                      _buildStatCount(
                          Image.asset("assets/icons/news_send1.png",
                              width: size.width * numD025,
                              height: size.width * numD025),
                          "$shareCount Shares"),
                      const SizedBox(width: 12),
                      _buildStatCount(
                          Image.asset("assets/icons/news_eye.png",
                              width: size.width * numD025,
                              height: size.width * numD025,
                              color: Color(0xFF4A4A4A)),
                          "$viewCount Views"),
                    ],
                  ),
                  // Right Side: Actions
                  Row(
                    children: [
                      _buildActionIcon(
                        _isLiked
                            ? Image.asset("assets/icons/new_heartfill.png",
                                width: size.width * numD04,
                                height: size.width * numD04)
                            : Image.asset("assets/icons/news_heart.png",
                                width: size.width * numD04,
                                height: size.width * numD04),
                        color: null, // Image already has color
                        onTap: () {
                          if (_userId.isEmpty) return;

                          ref
                              .read(mapControllerProvider.notifier)
                              .toggleNewsLike(widget.newsId);

                          setState(() {
                            _isLiked = !_isLiked;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      Builder(builder: (context) {
                        return _buildActionIcon(
                            Image.asset("assets/icons/news_send1.png",
                                width: size.width * numD04,
                                height: size.width * numD04), onTap: () {
                          _handleShare(context, currentIncident);
                        });
                      }),
                      const SizedBox(width: 8),
                      _buildActionIcon(
                          Image.asset("assets/icons/news_message1.png",
                              width: size.width * numD04,
                              height: size.width * numD04), onTap: () {
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
              ...ref
                  .watch(newsDetailsControllerProvider)
                  .comments
                  .map((comment) {
                if (comment.replies.isNotEmpty) {
                  return _buildThreadedComment(
                    commentData: comment,
                    onToggleExpand: () {
                      setState(() {
                        comment.isExpanded = !comment.isExpanded;
                      });
                    },
                    repliesWidgets: comment.replies
                        .map((reply) => _buildReplyComment(
                              id: reply.id,
                              name: reply.name,
                              date: reply.date,
                              comment: reply.comment,
                              avatarUrl: reply.avatarUrl,
                              parentId: comment.id,
                              isLiked: reply.isLiked,
                              likesCount: reply.likes,
                            ))
                        .toList(),
                  );
                } else {
                  return _buildSimpleComment(
                    id: comment.id,
                    name: comment.name,
                    date: comment.date,
                    comment: comment.comment,
                    avatarUrl: comment.avatarUrl,
                    likesCount: comment.likes,
                    isLiked: comment.isLiked,
                    replies: "${comment.replies.length} replies",
                  );
                }
              }).toList(),

              // Load More Text
              // Center(
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(vertical: 20.0),
              //     child: Text(
              //       "Load more comments",
              //       style: TextStyle(
              //         color: Colors.grey[500],
              //         fontSize: 12,
              //         fontWeight: FontWeight.w500,
              //       ),
              //     ),
              //   ),
              // ),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CommentInputWidget(
                  controller: _commentController,
                  onSend: () {
                    if (_commentController.text.trim().isNotEmpty) {
                      _addComment(_commentController.text.trim());
                      _commentController.clear();
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _replyingTo = null;
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
  }

  Widget _buildStatCount(Widget icon, String text) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
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
      // Format: hh:mm a dd MMM yyyy
      return DateFormat('hh:mm a dd MMM yyyy').format(parsed);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildActionIcon(Widget icon, {VoidCallback? onTap, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: icon,
    );
  }

  Widget _buildThreadedComment({
    required CommentData commentData,
    required List<Widget> repliesWidgets,
    required VoidCallback onToggleExpand,
  }) {
    final size = MediaQuery.of(context).size;
    bool isLiked = commentData.isLiked;
    final int extraRepliesCount = repliesWidgets.length - 1;

    return Column(
      key: _commentKeys[commentData.id] ??= GlobalKey(),
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
                    backgroundImage: commentData.avatarUrl.isNotEmpty
                        ? NetworkImage(commentData.avatarUrl)
                        : null,
                    backgroundColor: Colors.grey[200],
                    child: commentData.avatarUrl.isEmpty
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
                            text: commentData.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                          TextSpan(
                            text: " • ${formatCommentDate(commentData.date)}",
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
                      textAlign: TextAlign.justify,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD03,
                          color: Colors.black,
                          lineHeight: 2,
                          fontWeight: FontWeight.normal),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.favorite_border,
                                size: 14, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text("${commentData.likes}",
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[500])),
                            const SizedBox(width: 16),
                            Icon(Icons.chat_bubble_outline,
                                size: 14, color: Color(0xFFEF4444)),
                            const SizedBox(width: 4),
                            Text("${commentData.replies.length} replies",
                                style: TextStyle(
                                    fontSize: 11, color: Color(0xFFEF4444))),
                          ],
                        ),
                        Row(
                          children: [
                            _buildActionIcon(
                              isLiked
                                  ? Image.asset(
                                      "assets/icons/new_heartfill.png",
                                      width: size.width * numD04,
                                      height: size.width * numD04)
                                  : Image.asset("assets/icons/news_heart.png",
                                      width: size.width * numD04,
                                      height: size.width * numD04),
                              onTap: () {
                                if (_userId.isEmpty) return;
                                ref
                                    .read(newsDetailsControllerProvider)
                                    .toggleLikeStatus(commentData.id, !isLiked);
                                _socketService.likeComment(
                                    contentId: widget.newsId,
                                    commentId: commentData.id,
                                    userId: _userId);
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildActionIcon(
                                Image.asset("assets/icons/news_send1.png",
                                    width: size.width * numD04,
                                    height: size.width * numD04), onTap: () {
                              // _handleShare(context, controller.incident!,
                              //     commentId: commentData.id);
                            }),
                            const SizedBox(width: 8),
                            _buildActionIcon(
                                Image.asset("assets/icons/news_message1.png",
                                    width: size.width * numD04,
                                    height: size.width * numD04), onTap: () {
                              setState(() {
                                _replyingTo = commentData.id;
                              });
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final key = _inputKeys[commentData.id];
                                if (key?.currentContext != null) {
                                  Scrollable.ensureVisible(
                                    key!.currentContext!,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    alignment: 0.5, // Center the input field
                                  );
                                }
                              });
                            }),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Stack(
          children: [
            Positioned(
              left: 18,
              top: 0,
              height: 16,
              child: Container(
                width: 1,
                color: Colors.grey[300],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Always show the first reply if it exists
                  if (repliesWidgets.isNotEmpty)
                    _buildThreadedReplyItem(
                      repliesWidgets[0],
                      isLast: repliesWidgets.length == 1,
                    ),

                  if (extraRepliesCount > 0 && !commentData.isExpanded)
                    Stack(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 18.0, bottom: 16.0),
                          child: InkWell(
                            onTap: onToggleExpand,
                            child: Row(children: [
                              Container(
                                width: 20,
                                height: 20,
                                child: Stack(
                                  children: [],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "See $extraRepliesCount replies",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: commentData.isExpanded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...repliesWidgets
                                  .skip(1)
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;
                                final reply = entry.value;

                                return _buildThreadedReplyItem(reply,
                                    isLast: false);
                              }).toList(),
                              _buildThreadedReplyItem(
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: InkWell(
                                    onTap: onToggleExpand,
                                    child: const Text(
                                      "Hide replies",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                isLast: true,
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  SizedBox(
                      key: _replyAnchors[commentData.id] ??= GlobalKey(),
                      height: 1),
                ],
              ),
            )
          ],
        ),
        if (_replyingTo == commentData.id) ...[
          Padding(
            padding: const EdgeInsets.only(left: 50.0, top: 8, bottom: 8),
            child: Container(
              key: _inputKeys[commentData.id] ??= GlobalKey(),
              child: CommentInputWidget(
                controller: _replyController,
                autofocus: true,
                onSend: () {
                  _addReply(commentData.id, _replyController.text);
                  _replyController.clear();
                  // Expand when adding a reply
                  if (!commentData.isExpanded) {
                    onToggleExpand();
                  }
                  setState(() {
                    _replyingTo = null;
                  });
                  // Scroll to bottom of thread
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final key = _replyAnchors[commentData.id];
                    if (key?.currentContext != null) {
                      Scrollable.ensureVisible(
                        key!.currentContext!,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        alignment: 0.5,
                      );
                    }
                  });
                },
                hintText: "Reply to ${commentData.name}...",
                height: 50,
              ),
            ),
          )
        ]
      ],
    );
  }

  Widget _buildThreadedReplyItem(Widget replyWidget, {bool isLast = false}) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          bottom: isLast ? null : 0,
          height: isLast ? 15.0 : null,
          child: Container(
            width: 1,
            color: Colors.grey[300],
          ),
        ),
        Positioned(
          left: 0,
          top: -5,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey[300]!, width: 1),
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 36.0, bottom: 20),
          child: replyWidget,
        ),
      ],
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
    // Check if it's Darlene to add the input box
    final size = MediaQuery.of(context).size;

    return Column(
      key: _commentKeys[id] ??= GlobalKey(),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundImage:
                  avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              backgroundColor: Colors.grey[200],
              child: avatarUrl.isEmpty
                  ? const Icon(Icons.person, size: 16, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 8),
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
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    comment,
                    textAlign: TextAlign.justify,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD03,
                        color: Colors.black,
                        lineHeight: 2,
                        fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.favorite_border,
                              size: 12, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                              isLiked
                                  ? "${likesCount + 1} likes"
                                  : "$likesCount likes",
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[500])),
                          const SizedBox(width: 12),
                          Icon(Icons.chat_bubble_outline,
                              size: 12, color: Color(0xFFEF4444)),
                          const SizedBox(width: 4),
                          Text("0 reply",
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xFFEF4444))),
                        ],
                      ),
                      Row(
                        children: [
                          _buildActionIcon(
                            isLiked
                                ? Image.asset("assets/icons/new_heartfill.png",
                                    width: size.width * numD04,
                                    height: size.width * numD04)
                                : Image.asset("assets/icons/news_heart.png",
                                    width: size.width * numD04,
                                    height: size.width * numD04),
                            onTap: () {
                              if (_userId.isEmpty) return;
                              ref
                                  .read(newsDetailsControllerProvider)
                                  .toggleLikeStatus(id, !isLiked);
                              _socketService.likeComment(
                                  contentId: widget.newsId,
                                  commentId: id,
                                  userId: _userId);
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionIcon(
                              Image.asset("assets/icons/news_send1.png",
                                  width: size.width * numD04,
                                  height: size.width * numD04), onTap: () {
                            // _handleShare(context, controller.incident!,
                            //     commentId: id);
                          }),
                          const SizedBox(width: 8),
                          _buildActionIcon(
                              Image.asset("assets/icons/news_message1.png",
                                  width: size.width * numD04,
                                  height: size.width * numD04), onTap: () {
                            print("Replying to $id");
                            setState(() {
                              _replyingTo = id;
                            });
                          }),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_replyingTo == id) ...[
          Padding(
            padding: const EdgeInsets.only(left: 50.0, top: 8, bottom: 8),
            child: CommentInputWidget(
              controller: _replyController,
              onSend: () {
                _addReply(parentId, _replyController.text);
                _replyController.clear();
                setState(() {
                  _replyingTo = null;
                });
              },
              hintText: "Reply to $name...",
              height: 50,
            ),
          )
        ]
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
    final size = MediaQuery.of(context).size;

    return Padding(
      key: _commentKeys[id] ??= GlobalKey(),
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      textAlign: TextAlign.justify,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD03,
                          color: Colors.black,
                          lineHeight: 2,
                          fontWeight: FontWeight.normal),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.favorite_border,
                                size: 14, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text(
                                isLiked
                                    ? "${likesCount + 1} likes"
                                    : "$likesCount likes",
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[500])),
                            const SizedBox(width: 16),
                            Icon(Icons.chat_bubble_outline,
                                size: 14, color: Color(0xFFEF4444)),
                            const SizedBox(width: 4),
                            Text(replies,
                                style: TextStyle(
                                    fontSize: 11, color: Color(0xFFEF4444))),
                          ],
                        ),
                        Row(
                          children: [
                            _buildActionIcon(
                              isLiked
                                  ? Image.asset(
                                      "assets/icons/new_heartfill.png",
                                      width: size.width * numD04,
                                      height: size.width * numD04)
                                  : Image.asset("assets/icons/news_heart.png",
                                      width: size.width * numD04,
                                      height: size.width * numD04),
                              onTap: () {
                                if (_userId.isEmpty) return;
                                ref
                                    .read(newsDetailsControllerProvider)
                                    .toggleLikeStatus(id, !isLiked);
                                _socketService.likeComment(
                                    contentId: widget.newsId,
                                    commentId: id,
                                    userId: _userId);
                              },
                            ),
                            /*
                            const SizedBox(width: 8),
                            Builder(builder: (context) {
                              final controller =
                                  ref.watch(newsDetailsControllerProvider);
                              return _buildActionIcon(
                                  Image.asset("assets/icons/news_send1.png",
                                      width: size.width * numD04,
                                      height: size.width * numD04), onTap: () {
                                _handleShare(context, controller.incident!,
                                    commentId: id);
                              });
                            }),
                            */
                            const SizedBox(width: 8),
                            _buildActionIcon(
                                Image.asset("assets/icons/news_message1.png",
                                    width: size.width * numD04,
                                    height: size.width * numD04), onTap: () {
                              setState(() {
                                _replyingTo = id;
                              });
                            }),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_replyingTo == id) ...[
            Padding(
              padding: const EdgeInsets.only(left: 50.0, top: 8, bottom: 8),
              child: CommentInputWidget(
                controller: _replyController,
                onSend: () {
                  _addReply(id, _replyController.text);
                  _replyController.clear();
                  setState(() {
                    _replyingTo = null;
                  });
                },
                hintText: "Reply to $name...",
                height: 50,
              ),
            )
          ]
        ],
      ),
    );
  }
}
