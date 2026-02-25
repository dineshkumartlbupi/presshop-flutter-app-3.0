import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/new_home_app_bar.dart';
import 'package:presshop/features/news/domain/entities/comment.dart';
import 'package:presshop/features/news/domain/entities/news.dart';
import 'package:presshop/features/news/presentation/bloc/news_bloc.dart';
import 'package:presshop/features/news/presentation/bloc/news_event.dart';
import 'package:presshop/features/news/presentation/bloc/news_state.dart';
import 'package:presshop/features/news/presentation/widgets/comment_input_widget.dart';
import 'package:presshop/features/news/presentation/widgets/news_media_widget.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

class NewsDetailPage extends StatefulWidget {
  final String newsId;
  final News? initialNews;
  final bool scrollToComments;
  final String? initialCommentId;

  const NewsDetailPage({
    Key? key,
    required this.newsId,
    this.initialNews,
    this.scrollToComments = false,
    this.initialCommentId,
  }) : super(key: key);

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage>
    with AnalyticsPageMixin {
  @override
  String get pageName => PageNames.newsDetailsScreen;

  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _commentsKey = GlobalKey();

  bool _isExpanded = false;
  bool _hasScrolledToComments = false;

  String? _replyingTo;
  String? _replyingToName;
  String? _rootParentId;

  final Map<String, GlobalKey> _inputKeys = {};
  final Map<String, GlobalKey> _commentKeys = {};
  final Map<String, GlobalKey> _replyAnchors = {};
  final Map<String, bool> _expandedThreads = {};

  String _userId = "";

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final sharedPreferences = sl<SharedPreferences>();
    _userId =
        sharedPreferences.getString(SharedPreferencesKeys.hopperIdKey) ?? "";
    setState(() {});
  }

  void _addComment(BuildContext context, String text) {
    if (_userId.isEmpty) return;
    context.read<NewsBloc>().add(PostCommentEvent(
          contentId: widget.newsId,
          text: text,
        ));
    _commentController.clear();
  }

  void _addReply(BuildContext context, String parentId, String text,
      {String? rootParentId, String? replyToName}) {
    if (_userId.isEmpty) return;
    context.read<NewsBloc>().add(PostCommentEvent(
          contentId: widget.newsId,
          text: text,
          parentId: parentId,
          rootParentId: rootParentId,
          replyToName: replyToName,
        ));
    _replyController.clear();
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

  void _scrollToComment(String commentId) {
    if (!mounted) return;
    final key = _commentKeys[commentId];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(key!.currentContext!,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          alignment: 0.5);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleShare(BuildContext context, News currentNews) async {
    context.read<NewsBloc>().add(ShareNewsEvent(contentId: currentNews.id));
    final String shareText =
        "Check out this news: ${currentNews.title}\n\n${currentNews.description}\n\nRead more at: ${currentNews.mediaUrl ?? ''}";
    await Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (context) => sl<NewsBloc>()
        ..add(GetNewsDetailEvent(id: widget.newsId))
        ..add(GetCommentsEvent(contentId: widget.newsId))
        ..add(ViewNewsEvent(contentId: widget.newsId))
        ..add(IncrementViewCountEvent()),
      child: BlocConsumer<NewsBloc, NewsState>(
        listener: (context, state) {
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

          if (widget.initialCommentId != null && !state.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(milliseconds: 1500), () {
                _scrollToComment(widget.initialCommentId!);
              });
            });
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.selectedNews == null) {
            return Scaffold(
              body: Center(child: showAnimatedLoader(size)),
            );
          }

          final currentNews = state.selectedNews ?? widget.initialNews;

          if (currentNews == null) {
            return Scaffold(
              appBar: NewHomeAppBar(
                size: size,
                hideLeading: false,
                appBarTitle: "News details",
              ),
              body: Center(
                child: Text(state.errorMessage ?? "News Not Found"),
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

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: NewHomeAppBar(
              size: size,
              hideLeading: false,
              appBarTitle: "News details",
              hideHamburger: true,
              showFilter: false,
            ),
            body: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: EdgeInsets.all(size.width * AppDimensions.numD04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                          size.width * AppDimensions.numD04),
                      child: NewsMediaWidget(
                        mediaUrl: currentNews.mediaUrl ?? "",
                        imageUrl: currentNews.mediaUrl ?? "",
                        isVideo: currentNews.mediaType == 'video',
                        size: size,
                      ),
                    ),
                    SizedBox(height: size.width * AppDimensions.numD04),
                    _buildAuthorRow(currentNews, size),
                    SizedBox(height: size.width * AppDimensions.numD04),
                    Text(
                      currentNews.title,
                      textAlign: TextAlign.justify,
                      style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD04,
                        color: Colors.black,
                        lineHeight: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: size.width * AppDimensions.numD03),
                    _buildDescription(description, size),
                    SizedBox(height: size.width * AppDimensions.numD06),
                    _buildStatsRow(context, currentNews, size, isLiked,
                        likeCount, commentCount, shareCount, viewCount),
                    SizedBox(height: size.width * AppDimensions.numD06),
                    Text(
                      "Comments",
                      key: _commentsKey,
                      style: TextStyle(
                        fontSize: size.width * AppDimensions.numD045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: size.width * AppDimensions.numD05),
                    _buildCommentsList(context, state, size),
                    _buildLoadMoreComments(context, state, size),
                    _buildMainCommentInput(context, size),
                    SizedBox(height: size.width * AppDimensions.numD05),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAuthorRow(News news, Size size) {
    return Row(
      children: [
        CircleAvatar(
          radius: size.width * AppDimensions.numD03,
          backgroundColor: Colors.red[900],
          backgroundImage:
              (news.userImage != null && news.userImage!.isNotEmpty)
                  ? NetworkImage(news.userImage!)
                  : null,
          child: (news.userImage == null || news.userImage!.isEmpty)
              ? Text(
                  (news.userName != null && news.userName!.isNotEmpty)
                      ? news.userName![0].toUpperCase()
                      : "J",
                  style: TextStyle(
                      fontSize: size.width * AppDimensions.numD03,
                      color: Colors.white))
              : null,
        ),
        SizedBox(width: size.width * AppDimensions.numD02),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  news.userName ?? 'Unknown',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: size.width * AppDimensions.numD03,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: size.width * AppDimensions.numD02),
                Image.asset(
                  "${iconsPath}ic_clock.png",
                  height: size.width * AppDimensions.numD03,
                  color: Colors.grey[500],
                ),
                SizedBox(width: size.width * AppDimensions.numD01),
                _buildTimeText(news.createdAt, size),
                SizedBox(width: size.width * AppDimensions.numD02),
                Image.asset(
                  "${iconsPath}ic_yearly_calendar.png",
                  height: size.width * AppDimensions.numD03,
                  color: Colors.grey[500],
                ),
                SizedBox(width: size.width * AppDimensions.numD01),
                _buildDateText(news.createdAt, size),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeText(String? createdAt, Size size) {
    if (createdAt == null) return const SizedBox();
    DateTime? parsed = DateTime.tryParse(createdAt);
    String displayTime = parsed != null
        ? DateFormat('hh:mm a').format(parsed.toLocal())
        : createdAt;
    return Text(
      displayTime,
      style: TextStyle(
          color: Colors.grey[500], fontSize: size.width * AppDimensions.numD03),
    );
  }

  Widget _buildDateText(String? createdAt, Size size) {
    if (createdAt == null) return const SizedBox();
    DateTime? parsed = DateTime.tryParse(createdAt);
    String displayDate = parsed != null
        ? DateFormat("dd MMM yyyy").format(parsed.toLocal())
        : "";
    return Text(
      displayDate,
      style: TextStyle(
          color: Colors.grey[500], fontSize: size.width * AppDimensions.numD03),
    );
  }

  Widget _buildDescription(String description, Size size) {
    const int threshold = 500;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isExpanded
              ? description
              : (description.length > threshold
                  ? "${description.substring(0, threshold)}..."
                  : description),
          textAlign: TextAlign.justify,
          style: commonTextStyle(
            size: size,
            fontSize: size.width * AppDimensions.numD03,
            color: Colors.black,
            lineHeight: 2,
            fontWeight: FontWeight.normal,
          ),
        ),
        if (description.length > threshold)
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Text(
              _isExpanded ? "Read Less" : "Read More...",
              style: TextStyle(
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
                fontSize: size.width * AppDimensions.numD031,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsRow(
      BuildContext context,
      News news,
      Size size,
      bool isLiked,
      int likeCount,
      int commentCount,
      int shareCount,
      int viewCount) {
    final double iconSize = size.width * AppDimensions.numD031;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildStatItem(
                "assets/icons/news_heart.png",
                "$likeCount ${likeCount == 1 || likeCount == 0 ? 'like' : 'likes'}",
                size,
                iconSize),
            SizedBox(width: size.width * AppDimensions.numD03),
            _buildStatItem(
                "assets/icons/news_message1.png",
                "$commentCount ${commentCount == 1 || commentCount == 0 ? 'comment' : 'comments'}",
                size,
                iconSize),
            SizedBox(width: size.width * AppDimensions.numD03),
            _buildStatItem(
                "assets/icons/news_send1.png",
                "$shareCount ${shareCount == 1 || shareCount == 0 ? 'share' : 'shares'}",
                size,
                iconSize),
            SizedBox(width: size.width * AppDimensions.numD03),
            _buildStatItem(
                "assets/icons/news_eye.png",
                "$viewCount ${viewCount == 1 || viewCount == 0 ? 'view' : 'views'}",
                size,
                size.width * AppDimensions.numD035,
                color: const Color(0xFF4A4A4A)),
          ],
        ),
        Row(
          children: [
            _buildActionIcon(
              GestureDetector(
                onTap: () => context
                    .read<NewsBloc>()
                    .add(ToggleNewsLikeEvent(contentId: news.id)),
                child: Image.asset(
                  isLiked
                      ? "assets/icons/new_heartfill.png"
                      : "assets/icons/news_heart.png",
                  width: size.width * AppDimensions.numD04,
                  height: size.width * AppDimensions.numD04,
                ),
              ),
            ),
            SizedBox(width: size.width * AppDimensions.numD02),
            _buildActionIcon(
              GestureDetector(
                onTap: () => _handleShare(context, news),
                child: Image.asset(
                  "assets/icons/news_send1.png",
                  width: size.width * AppDimensions.numD04,
                  height: size.width * AppDimensions.numD04,
                ),
              ),
            ),
            SizedBox(width: size.width * AppDimensions.numD02),
            _buildActionIcon(
              GestureDetector(
                onTap: () => _scrollToComments(),
                child: Image.asset(
                  "assets/icons/news_message1.png",
                  width: size.width * AppDimensions.numD04,
                  height: size.width * AppDimensions.numD04,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String asset, String text, Size size, double iconSize,
      {Color? color}) {
    return Row(
      children: [
        Image.asset(asset, width: iconSize, height: iconSize, color: color),
        SizedBox(width: size.width * AppDimensions.numD01),
        Text(
          text,
          style: TextStyle(
            fontSize: size.width * AppDimensions.numD025,
            color: const Color(0xFF4A4A4A),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcon(Widget child) => child;

  Widget _buildCommentsList(BuildContext context, NewsState state, Size size) {
    return Column(
      children: state.comments.map((comment) {
        if (comment.replies.isNotEmpty) {
          return _buildThreadedComment(
            context: context,
            commentData: comment,
            size: size,
            onToggleExpand: () {
              setState(() {
                _expandedThreads[comment.id] =
                    !(_expandedThreads[comment.id] ?? false);
              });
            },
            repliesWidgets: comment.replies
                .map((reply) => _buildReplyComment(
                      context: context,
                      id: reply.id,
                      name: reply.userName ?? "Unknown",
                      date: reply.createdAt,
                      commentContent: reply.comment,
                      avatarUrl: reply.userImage ?? "",
                      parentId: comment.id,
                      isLiked: reply.isLiked,
                      likesCount: reply.likesCount,
                      repliesCount: reply.replies.length,
                      replyToName: reply.replyToName,
                      size: size,
                    ))
                .toList(),
          );
        } else {
          return _buildSimpleComment(
            context: context,
            id: comment.id,
            name: comment.userName ?? "Unknown",
            date: comment.createdAt,
            commentContent: comment.comment,
            avatarUrl: comment.userImage ?? "",
            likesCount: comment.likesCount,
            isLiked: comment.isLiked,
            repliesCount: 0,
            size: size,
          );
        }
      }).toList(),
    );
  }

  Widget _buildLoadMoreComments(
      BuildContext context, NewsState state, Size size) {
    if (state.isLoadingComments) {
      return Padding(
        padding: EdgeInsets.all(size.width * AppDimensions.numD04),
        child: const Center(child: CircularProgressIndicator()),
      );
    } else if (state.hasMoreComments && state.comments.isNotEmpty) {
      return Center(
        child: TextButton(
          onPressed: () {
            context.read<NewsBloc>().add(GetCommentsEvent(
                  contentId: widget.newsId,
                  offset: state.comments.length,
                ));
          },
          child: Text(
            "Load more comments",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: size.width * AppDimensions.numD03,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMainCommentInput(BuildContext context, Size size) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * AppDimensions.numD04,
          vertical: size.width * AppDimensions.numD03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * AppDimensions.numD02),
      ),
      child: CommentInputWidget(
        controller: _commentController,
        onSend: () {
          if (_commentController.text.trim().isNotEmpty) {
            _addComment(context, _commentController.text.trim());
            FocusScope.of(context).unfocus();
          }
        },
      ),
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

  Widget _buildThreadedComment({
    required BuildContext context,
    required Comment commentData,
    required List<Widget> repliesWidgets,
    required VoidCallback onToggleExpand,
    required Size size,
  }) {
    bool isLiked = commentData.isLiked;
    bool isExpanded = _expandedThreads[commentData.id] ?? false;

    return Column(
      key: _commentKeys[commentData.id] ??= GlobalKey(),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: size.width * AppDimensions.numD05,
                    backgroundImage: (commentData.userImage != null &&
                            commentData.userImage!.isNotEmpty)
                        ? NetworkImage(commentData.userImage!)
                        : null,
                    backgroundColor: Colors.grey[200],
                    child: (commentData.userImage == null ||
                            commentData.userImage!.isEmpty)
                        ? Icon(Icons.person,
                            color: Colors.grey,
                            size: size.width * AppDimensions.numD04)
                        : null,
                  ),
                  Expanded(
                    child: Container(
                      width: size.width * AppDimensions.numD003,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
              SizedBox(width: size.width * AppDimensions.numD03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCommentHeader(commentData.userName ?? "Unknown",
                        commentData.createdAt, size),
                    SizedBox(height: size.width * AppDimensions.numD01),
                    Text(
                      commentData.comment,
                      textAlign: TextAlign.justify,
                      style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD03,
                        color: Colors.black,
                        lineHeight: 2,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: size.width * AppDimensions.numD02),
                    _buildCommentActions(
                        context,
                        commentData.id,
                        commentData.userName ?? "Unknown",
                        isLiked,
                        commentData.likesCount,
                        size),
                  ],
                ),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            Positioned(
              left: size.width * AppDimensions.numD05 -
                  (size.width * AppDimensions.numD003 / 2),
              top: 0,
              height: size.width * AppDimensions.numD04,
              child: Container(
                  width: size.width * AppDimensions.numD003,
                  color: Colors.grey[300]),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: size.width * AppDimensions.numD05 -
                    (size.width * AppDimensions.numD003 / 2),
                top: size.width * AppDimensions.numD04,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (repliesWidgets.isNotEmpty)
                    _buildThreadedReplyItem(repliesWidgets[0], size,
                        isLast: !isExpanded && repliesWidgets.length == 1),
                  if (repliesWidgets.length > 1 && !isExpanded)
                    _buildSeeRepliesLink(
                        repliesWidgets.length - 1, onToggleExpand, size),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: isExpanded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...repliesWidgets
                                  .skip(1)
                                  .map((reply) => _buildThreadedReplyItem(
                                      reply, size,
                                      isLast: false))
                                  .toList(),
                              _buildThreadedReplyItem(
                                GestureDetector(
                                  onTap: onToggleExpand,
                                  child: Text("Hide replies",
                                      style: TextStyle(
                                          fontSize:
                                              size.width * AppDimensions.numD03,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey)),
                                ),
                                size,
                                isLast: true,
                                showConnector: false,
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
        if (_replyingTo == commentData.id)
          _buildReplyInputField(
              context,
              commentData.id,
              commentData.userName ?? "Unknown",
              commentData.id,
              onToggleExpand,
              size),
      ],
    );
  }

  Widget _buildCommentHeader(String name, String date, Size size) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
              text: name,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: size.width * AppDimensions.numD035)),
          TextSpan(
              text: " • ${formatCommentDate(date)}",
              style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: size.width * AppDimensions.numD03)),
        ],
      ),
    );
  }

  Widget _buildCommentActions(BuildContext context, String id, String name,
      bool isLiked, int likes, Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => context.read<NewsBloc>().add(ToggleCommentLikeEvent(
                  contentId: widget.newsId, commentId: id)),
              child: Row(children: [
                Image.asset(
                  isLiked
                      ? "assets/icons/new_heartfill.png"
                      : "assets/icons/news_heart.png",
                  width: size.width * AppDimensions.numD04,
                  height: size.width * AppDimensions.numD04,
                ),
                SizedBox(width: size.width * AppDimensions.numD01),
                Text("$likes likes",
                    style: TextStyle(
                        fontSize: size.width * AppDimensions.numD028,
                        color: Colors.grey[500])),
              ]),
            ),
            SizedBox(width: size.width * AppDimensions.numD04),
            GestureDetector(
              onTap: () {
                setState(() {
                  _replyingTo = id;
                  _replyingToName = name;
                });
                _scrollToInputField(id);
              },
              child: Row(children: [
                Image.asset("assets/icons/news_message1.png",
                    width: size.width * AppDimensions.numD04,
                    height: size.width * AppDimensions.numD04),
                SizedBox(width: size.width * AppDimensions.numD01),
                Text("Reply",
                    style: TextStyle(
                        fontSize: size.width * AppDimensions.numD031,
                        color: const Color(0xFFEF4444))),
              ]),
            ),
          ],
        ),
      ],
    );
  }

  void _scrollToInputField(String id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _inputKeys[id];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(key!.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.5);
      }
    });
  }

  Widget _buildThreadedReplyItem(Widget child, Size size,
      {bool isLast = false, bool showConnector = true}) {
    return Stack(
      children: [
        Positioned(
          left: -size.width * AppDimensions.numD003 / 2,
          top: 0,
          bottom: isLast ? null : 0,
          height: isLast ? size.width * AppDimensions.numD04 : null,
          child: Container(
              width: size.width * AppDimensions.numD003,
              color: Colors.grey[300]),
        ),
        if (showConnector)
          Positioned(
            left: -size.width * AppDimensions.numD003 / 2,
            top: -size.width * AppDimensions.numD025,
            child: Container(
              width: size.width * AppDimensions.numD13,
              height: size.width * AppDimensions.numD055,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                      color: Colors.grey[300]!,
                      width: size.width * AppDimensions.numD003),
                  bottom: BorderSide(
                      color: Colors.grey[300]!,
                      width: size.width * AppDimensions.numD003),
                ),
                borderRadius: BorderRadius.only(
                    bottomLeft:
                        Radius.circular(size.width * AppDimensions.numD03)),
              ),
            ),
          ),
        Padding(
            padding: EdgeInsets.only(
                left: size.width * AppDimensions.numD10,
                bottom: size.width * AppDimensions.numD055),
            child: child),
      ],
    );
  }

  Widget _buildSeeRepliesLink(int count, VoidCallback onTap, Size size) {
    return Padding(
      padding: EdgeInsets.only(
          left: size.width * AppDimensions.numD05,
          bottom: size.width * AppDimensions.numD04),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          "See $count replies",
          style: TextStyle(
              fontSize: size.width * AppDimensions.numD03,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildReplyInputField(BuildContext context, String id, String name,
      String rootId, VoidCallback onExpand, Size size) {
    return Padding(
      padding: EdgeInsets.only(
          left: size.width * AppDimensions.numD14,
          top: size.width * AppDimensions.numD02,
          bottom: size.width * AppDimensions.numD02),
      child: Container(
        key: _inputKeys[id] ??= GlobalKey(),
        child: CommentInputWidget(
          controller: _replyController,
          autofocus: true,
          hintText: "Reply to $name...",
          onSend: () {
            if (_replyController.text.trim().isNotEmpty) {
              _addReply(context, id, _replyController.text.trim(),
                  rootParentId: rootId, replyToName: name);
              if (!(_expandedThreads[rootId] ?? false)) onExpand();
              setState(() => _replyingTo = null);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSimpleComment({
    required BuildContext context,
    required String id,
    required String name,
    required String date,
    required String commentContent,
    required String avatarUrl,
    required int likesCount,
    required bool isLiked,
    required int repliesCount,
    required Size size,
  }) {
    return Padding(
      key: _commentKeys[id] ??= GlobalKey(),
      padding: EdgeInsets.only(bottom: size.width * AppDimensions.numD06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: size.width * AppDimensions.numD05,
                backgroundImage:
                    avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                backgroundColor: Colors.grey[200],
                child: avatarUrl.isEmpty
                    ? Icon(Icons.person,
                        color: Colors.grey,
                        size: size.width * AppDimensions.numD04)
                    : null,
              ),
              SizedBox(width: size.width * AppDimensions.numD03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCommentHeader(name, date, size),
                    SizedBox(height: size.width * AppDimensions.numD01),
                    Text(
                      commentContent,
                      textAlign: TextAlign.justify,
                      style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD03,
                        color: Colors.black,
                        lineHeight: 2,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: size.width * AppDimensions.numD02),
                    _buildCommentActions(
                        context, id, name, isLiked, likesCount, size),
                  ],
                ),
              ),
            ],
          ),
          if (_replyingTo == id)
            _buildReplyInputField(context, id, name, id, () {}, size),
        ],
      ),
    );
  }

  Widget _buildReplyComment({
    required BuildContext context,
    required String id,
    required String name,
    required String date,
    required String commentContent,
    required String avatarUrl,
    required String parentId,
    required bool isLiked,
    required int likesCount,
    required int repliesCount,
    String? replyToName,
    required Size size,
  }) {
    return Column(
      key: _commentKeys[id] ??= GlobalKey(),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: size.width * AppDimensions.numD03,
              backgroundImage:
                  avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              backgroundColor: Colors.grey[200],
              child: avatarUrl.isEmpty
                  ? Icon(Icons.person,
                      size: size.width * AppDimensions.numD04,
                      color: Colors.grey)
                  : null,
            ),
            SizedBox(width: size.width * AppDimensions.numD02),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCommentHeader(name, date, size),
                  SizedBox(height: size.width * AppDimensions.numD005),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      children: [
                        if (replyToName != null && replyToName.isNotEmpty)
                          TextSpan(
                            text: "@$replyToName ",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD03,
                                color: const Color(0xFFEF4444),
                                lineHeight: 2,
                                fontWeight: FontWeight.w700),
                          ),
                        TextSpan(
                          text: commentContent,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD03,
                              color: Colors.black,
                              lineHeight: 2,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.width * AppDimensions.numD015),
                  _buildCommentActions(
                      context, id, name, isLiked, likesCount, size),
                ],
              ),
            ),
          ],
        ),
        if (_replyingTo == id)
          _buildReplyInputField(context, id, name, parentId, () {}, size),
      ],
    );
  }
}
