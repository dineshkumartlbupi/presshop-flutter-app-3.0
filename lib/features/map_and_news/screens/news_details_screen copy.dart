// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:presshop/utils/Common.dart';
// import 'package:presshop/utils/CommonAppBar.dart';
// import 'package:presshop/utils/CommonWigdets.dart';
// import 'package:presshop/view/dashboard/Dashboard.dart';
// import 'package:presshop/view/map_and_news/constants/map_news_constants.dart';
// import 'package:presshop/view/map_and_news/controller/news_details_controller.dart';
// import 'package:presshop/view/map_and_news/models/marker_model.dart';
// import 'package:presshop/view/map_and_news/widgets/comment_input_widget.dart';
// import 'package:share_plus/share_plus.dart';

// class NewsDetailsScreen extends ConsumerStatefulWidget {
//   final String newsId;
//   final bool scrollToComments;

//   const NewsDetailsScreen({
//     Key? key,
//     required this.newsId,
//     this.scrollToComments = false,
//   }) : super(key: key);

//   @override
//   ConsumerState<NewsDetailsScreen> createState() => _NewsDetailsScreenState();
// }

// class _NewsDetailsScreenState extends ConsumerState<NewsDetailsScreen> {
//   final TextEditingController _commentController = TextEditingController();
//   final TextEditingController _replyController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final GlobalKey _commentsKey = GlobalKey();

//   bool _isExpanded = false;
//   bool _isLiked = false;

//   final Set<String> _likedComments = {};
//   String? _replyingTo;
//   final Map<String, GlobalKey> _inputKeys = {};
//   final Map<String, GlobalKey> _replyAnchors = {};

//   List<CommentData> _comments = [];

//   @override
//   void initState() {
//     super.initState();

//     // Fetch full details
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(newsDetailsControllerProvider).fetchNewsDetails(widget.newsId);
//     });

//     // Initialize dummy comments

//     if (widget.scrollToComments) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _scrollToComments();
//       });
//     }
//   }

//   void _addComment(String text) {
//     setState(() {
//       _comments.insert(
//         0,
//         CommentData(
//           id: DateTime.now().toString(),
//           name: "You (Demo)",
//           date: "Just now",
//           comment: text,
//           avatarUrl:
//               "https://i.pravatar.cc/150?u=${DateTime.now().millisecond}",
//           likes: 0,
//           replies: [],
//         ),
//       );
//     });
//   }

//   void _addReply(String parentId, String text) {
//     setState(() {
//       for (var comment in _comments) {
//         if (comment.id == parentId) {
//           comment.replies.add(
//             CommentData(
//               id: DateTime.now().toString(),
//               name: "You (Demo)",
//               date: "Just now",
//               comment: text,
//               avatarUrl:
//                   "https://i.pravatar.cc/150?u=${DateTime.now().millisecond}",
//               likes: 0,
//             ),
//           );
//           break;
//         }
//       }
//     });
//   }

//   void _scrollToComments() {
//     if (_commentsKey.currentContext != null) {
//       Scrollable.ensureVisible(
//         _commentsKey.currentContext!,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _commentController.dispose();
//     _replyController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   int get _totalCommentCount {
//     int count = _comments.length;
//     for (var c in _comments) {
//       count += c.replies.length;
//     }
//     return count;
//   }

//   void _handleShare(BuildContext context, Incident currentIncident) {
//     final String text =
//         'Check out this news: ${currentIncident.title ?? "News Update"}\n${currentIncident.description ?? ""}';
//     final box = context.findRenderObject() as RenderBox?;
//     if (box != null) {
//       Share.share(
//         text,
//         sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
//       );
//     } else {
//       Share.share(text);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final controller = ref.watch(newsDetailsControllerProvider);
//     final currentIncident = controller.incident;

//     final size = MediaQuery.of(context).size;

//     if (controller.isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (currentIncident == null) {
//       return Scaffold(
//         appBar: CommonAppBar(
//           elevation: 0,
//           hideLeading: false,
//           title: const Text("News details"),
//           centerTitle: true,
//           titleSpacing: 0,
//           size: size,
//           showActions: false,
//           leadingFxn: () => Navigator.pop(context),
//           actionWidget: [],
//         ),
//         body: Center(
//           child: Text(controller.error ?? "Failed to load news details"),
//         ),
//       );
//     }

//     final description = currentIncident.description ?? "";

//     // Stats from API or fallback
//     final likeCount = currentIncident.likesCount ?? 1900;
//     final commentCount = currentIncident.commentsCount ?? _totalCommentCount;
//     final shareCount = currentIncident.sharesCount ?? 111;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: CommonAppBar(
//         elevation: 0,
//         hideLeading: false,
//         title: Padding(
//           padding: EdgeInsets.only(left: false ? size.width * numD04 : 0),
//           child: Text(
//             "News details",
//             style: TextStyle(
//                 color: Colors.black,
//                 fontWeight: FontWeight.bold,
//                 fontSize: size.width * appBarHeadingFontSize),
//           ),
//         ),
//         centerTitle: false,
//         titleSpacing: 0,
//         size: size,
//         showActions: true,
//         leadingFxn: () {
//           Navigator.pop(context);
//         },
//         actionWidget: [
//           SizedBox(
//             width: size.width * numD02,
//           ),
//           InkWell(
//             onTap: () {
//               Navigator.of(context).pushAndRemoveUntil(
//                   MaterialPageRoute(
//                       builder: (context) => Dashboard(initialPosition: 2)),
//                   (route) => false);
//             },
//             child: Image.asset(
//               "${commonImagePath}rabbitLogo.png",
//               height: size.width * numD07,
//               width: size.width * numD07,
//             ),
//           ),
//           SizedBox(
//             width: size.width * numD04,
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         controller: _scrollController,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Video/Image Section
//               Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(16),
//                     child: currentIncident.image != null
//                         ? CachedNetworkImage(
//                             imageUrl: currentIncident.image!,
//                             height: 220,
//                             width: double.infinity,
//                             fit: BoxFit.cover,
//                             placeholder: (context, url) => Container(
//                               height: 220,
//                               color: Colors.grey[200],
//                               child: const Center(
//                                 child: CircularProgressIndicator(),
//                               ),
//                             ),
//                             errorWidget: (context, url, error) => Container(
//                               height: 220,
//                               color: Colors.grey[300],
//                               child: const Icon(Icons.error),
//                             ),
//                           )
//                         : Container(
//                             height: 220,
//                             width: double.infinity,
//                             color: Colors.grey[300],
//                             child: const Icon(Icons.image, size: 50),
//                           ),
//                   ),
//                   Container(
//                     width: 50,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.4),
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.white, width: 2),
//                     ),
//                     child: const Icon(
//                       Icons.play_arrow_rounded,
//                       color: Colors.white,
//                       size: 30,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),

//               // Author Row
//               Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 12,
//                     backgroundColor: Colors.red[900],
//                     child: const Text("J", style: TextStyle(fontSize: 12)),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     "${currentIncident.author ?? 'Jamuna TV'} • ${currentIncident.date ?? '11 feb 2026'} • ${currentIncident.time ?? '10:40 AM'}",
//                     style: TextStyle(
//                       color: Colors.grey[500],
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),

//               // Title
//               Text(
//                 currentIncident.title ??
//                     "Car accident near Oxford Street causes heavy traffic delays today.",
//                 style: commonTextStyle(
//                     size: size,
//                     fontSize: size.width * numD04,
//                     color: Colors.black,
//                     lineHeight: 1.5,
//                     fontWeight: FontWeight.w700),
//               ),
//               const SizedBox(height: 12),

//               // Description
//               Text(
//                 _isExpanded
//                     ? description
//                     : (description.length > 200
//                         ? "${description.substring(0, 200)}..."
//                         : description),
//                 textAlign: TextAlign.justify,
//                 style: commonTextStyle(
//                     size: size,
//                     fontSize: size.width * numD03,
//                     color: Colors.black,
//                     lineHeight: 2,
//                     fontWeight: FontWeight.normal),
//               ),
//               if (description.length > 200) ...[
//                 const SizedBox(height: 4),
//                 GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _isExpanded = !_isExpanded;
//                     });
//                   },
//                   child: Text(
//                     _isExpanded ? "Read Less" : "Read More...",
//                     style: const TextStyle(
//                       color: Color(0xFFEF4444),
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//               ],
//               const SizedBox(height: 24),

//               // Stats Row
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Left Side: Stats
//                   Row(
//                     children: [
//                       _buildStatCount(
//                           _isLiked
//                               ? Image.asset("assets/icons/new_heartfill.png",
//                                   width: size.width * numD025,
//                                   height: size.width * numD025)
//                               : Image.asset("assets/icons/news_heart.png",
//                                   width: size.width * numD025,
//                                   height: size.width * numD025),
//                           "$likeCount likes"),
//                       const SizedBox(width: 12),
//                       _buildStatCount(
//                           Image.asset("assets/icons/news_message1.png",
//                               width: size.width * numD025,
//                               height: size.width * numD025),
//                           "$commentCount Comments"),
//                       const SizedBox(width: 12),
//                       _buildStatCount(
//                           Image.asset("assets/icons/news_send1.png",
//                               width: size.width * numD025,
//                               height: size.width * numD025),
//                           "$shareCount Shares"),
//                     ],
//                   ),
//                   // Right Side: Actions
//                   Row(
//                     children: [
//                       _buildActionIcon(
//                         _isLiked
//                             ? Image.asset("assets/icons/new_heartfill.png",
//                                 width: size.width * numD04,
//                                 height: size.width * numD04)
//                             : Image.asset("assets/icons/news_heart.png",
//                                 width: size.width * numD04,
//                                 height: size.width * numD04),
//                         color: null, // Image already has color
//                         onTap: () {
//                           // This should ideally call an API to toggle like
//                           setState(() {
//                             _isLiked = !_isLiked;
//                           });
//                         },
//                       ),
//                       const SizedBox(width: 8),
//                       Builder(builder: (context) {
//                         return _buildActionIcon(
//                             Image.asset("assets/icons/news_send1.png",
//                                 width: size.width * numD04,
//                                 height: size.width * numD04), onTap: () {
//                           _handleShare(context, currentIncident);
//                         });
//                       }),
//                       const SizedBox(width: 8),
//                       _buildActionIcon(
//                           Image.asset("assets/icons/news_message1.png",
//                               width: size.width * numD04,
//                               height: size.width * numD04), onTap: () {
//                         _scrollToComments();
//                       }),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),

//               // Comments Header
//               Text(
//                 "Comments",
//                 key: _commentsKey,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Comments Section
//               ...comments.map((comment) {
//                 if (comment.replies.isNotEmpty) {
//                   return _buildThreadedComment(
//                     commentData: comment,
//                     onToggleExpand: () {
//                       setState(() {
//                         comment.isExpanded = !comment.isExpanded;
//                       });
//                     },
//                     repliesWidgets: comment.replies
//                         .map((reply) => _buildReplyComment(
//                               id: reply.id,
//                               name: reply.name,
//                               date: reply.date,
//                               comment: reply.comment,
//                               avatarUrl: reply.avatarUrl,
//                               parentId: comment.id,
//                             ))
//                         .toList(),
//                   );
//                 } else {
//                   return _buildSimpleComment(
//                     id: comment.id,
//                     name: comment.name,
//                     date: comment.date,
//                     comment: comment.comment,
//                     avatarUrl: comment.avatarUrl,
//                     likes: "${comment.likes} likes",
//                     replies: "${comment.replies.length} replies",
//                   );
//                 }
//               }).toList(),

//               // Load More Text
//               Center(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 20.0),
//                   child: Text(
//                     "Load more comments",
//                     style: TextStyle(
//                       color: Colors.grey[500],
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),

//               // Bottom Input Field (Non-sticky)
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,

//                   borderRadius: BorderRadius.circular(
//                       8), // Kept outer radius if needed, though usually bottom bars are square or top-rounded
//                 ),
//                 child: CommentInputWidget(
//                   controller: _commentController,
//                   onSend: () {
//                     if (_commentController.text.trim().isNotEmpty) {
//                       _addComment(_commentController.text.trim());
//                       _commentController.clear();
//                       FocusScope.of(context).unfocus();
//                       setState(() {
//                         _replyingTo = null;
//                       });
//                     }
//                   },
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatCount(Widget icon, String text) {
//     return Row(
//       children: [
//         icon,
//         const SizedBox(width: 4),
//         Text(
//           text,
//           style: TextStyle(
//             fontSize: 8,
//             color: Color(0xFF4A4A4A),
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildActionIcon(Widget icon, {VoidCallback? onTap, Color? color}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: icon,
//     );
//   }

//   Widget _buildThreadedComment({
//     required CommentData commentData,
//     required List<Widget> repliesWidgets,
//     required VoidCallback onToggleExpand,
//   }) {
//     final size = MediaQuery.of(context).size;
//     bool isLiked = _likedComments.contains(commentData.id);
//     final int extraRepliesCount = repliesWidgets.length - 1;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Parent Comment
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CircleAvatar(
//               radius: 18,
//               backgroundImage: NetworkImage(commentData.avatarUrl),
//               backgroundColor: Colors.grey[200],
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   RichText(
//                     text: TextSpan(
//                       children: [
//                         TextSpan(
//                           text: commentData.name,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black,
//                             fontSize: 13,
//                           ),
//                         ),
//                         TextSpan(
//                           text: " • ${commentData.date}",
//                           style: TextStyle(
//                             color: Colors.grey[500],
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     commentData.comment,
//                     textAlign: TextAlign.justify,
//                     style: commonTextStyle(
//                         size: size,
//                         fontSize: size.width * numD03,
//                         color: Colors.black,
//                         lineHeight: 2,
//                         fontWeight: FontWeight.normal),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.favorite_border,
//                               size: 14, color: Colors.grey[400]),
//                           const SizedBox(width: 4),
//                           Text(isLiked ? "201 likes" : "200 likes",
//                               style: TextStyle(
//                                   fontSize: 11, color: Colors.grey[500])),
//                           const SizedBox(width: 16),
//                           Icon(Icons.chat_bubble_outline,
//                               size: 14, color: Color(0xFFEF4444)),
//                           const SizedBox(width: 4),
//                           Text("${commentData.replies.length} replies",
//                               style: TextStyle(
//                                   fontSize: 11, color: Color(0xFFEF4444))),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           _buildActionIcon(
//                             isLiked
//                                 ? Image.asset("assets/icons/new_heartfill.png",
//                                     width: size.width * numD04,
//                                     height: size.width * numD04)
//                                 : Image.asset("assets/icons/news_heart.png",
//                                     width: size.width * numD04,
//                                     height: size.width * numD04),
//                             onTap: () {
//                               setState(() {
//                                 if (isLiked) {
//                                   _likedComments.remove(commentData.id);
//                                 } else {
//                                   _likedComments.add(commentData.id);
//                                 }
//                               });
//                             },
//                           ),
//                           const SizedBox(width: 8),
//                           Builder(builder: (context) {
//                             return _buildActionIcon(
//                                 Image.asset("assets/icons/news_send1.png",
//                                     width: size.width * numD04,
//                                     height: size.width * numD04), onTap: () {
//                               Share.share("Check this out!");
//                             });
//                           }),
//                           const SizedBox(width: 8),
//                           _buildActionIcon(
//                               Image.asset("assets/icons/news_message1.png",
//                                   width: size.width * numD04,
//                                   height: size.width * numD04), onTap: () {
//                             setState(() {
//                               _replyingTo = commentData.id;
//                             });
//                             WidgetsBinding.instance.addPostFrameCallback((_) {
//                               final key = _inputKeys[commentData.id];
//                               if (key?.currentContext != null) {
//                                 Scrollable.ensureVisible(
//                                   key!.currentContext!,
//                                   duration: const Duration(milliseconds: 300),
//                                   curve: Curves.easeInOut,
//                                   alignment: 0.5, // Center the input field
//                                 );
//                               }
//                             });
//                           }),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),

//         // Replies with Thread Line
//         Stack(
//           children: [
//             Positioned(
//               left: 18,
//               top: 0,
//               bottom: 0,
//               child: Container(
//                 width: 1,
//                 color: Colors.grey[300],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 18.0, top: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Always show the first reply if it exists
//                   if (repliesWidgets.isNotEmpty)
//                     _buildThreadedReplyItem(repliesWidgets[0]),

//                   // Show "See X replies" button if hidden replies exist
//                   if (extraRepliesCount > 0 && !commentData.isExpanded)
//                     Padding(
//                       padding: const EdgeInsets.only(left: 36.0, bottom: 16.0),
//                       child: InkWell(
//                         onTap: onToggleExpand,
//                         child: Row(children: [
//                           Container(
//                             width: 20,
//                             height: 1,
//                             color: Colors.grey[300],
//                             margin: const EdgeInsets.only(right: 8),
//                           ),
//                           Text(
//                             "See $extraRepliesCount replies",
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ]),
//                       ),
//                     ),

//                   // Animated expansion for the rest
//                   AnimatedSize(
//                     duration: const Duration(milliseconds: 300),
//                     curve: Curves.easeInOut,
//                     child: commentData.isExpanded
//                         ? Column(
//                             children: repliesWidgets
//                                 .skip(1)
//                                 .map((reply) => _buildThreadedReplyItem(reply))
//                                 .toList(),
//                           )
//                         : const SizedBox.shrink(),
//                   ),
//                   // Anchor to scroll to after adding a reply
//                   SizedBox(
//                       key: _replyAnchors[commentData.id] ??= GlobalKey(),
//                       height: 1),
//                 ],
//               ),
//             )
//           ],
//         ),
//         if (_replyingTo == commentData.id) ...[
//           Padding(
//             padding: const EdgeInsets.only(left: 50.0, top: 8, bottom: 8),
//             child: Container(
//               key: _inputKeys[commentData.id] ??= GlobalKey(),
//               child: CommentInputWidget(
//                 controller: _replyController,
//                 autofocus: true,
//                 onSend: () {
//                   _addReply(commentData.id, _replyController.text);
//                   _replyController.clear();
//                   // Expand when adding a reply
//                   if (!commentData.isExpanded) {
//                     onToggleExpand();
//                   }
//                   setState(() {
//                     _replyingTo = null;
//                   });
//                   // Scroll to bottom of thread
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     final key = _replyAnchors[commentData.id];
//                     if (key?.currentContext != null) {
//                       Scrollable.ensureVisible(
//                         key!.currentContext!,
//                         duration: const Duration(milliseconds: 300),
//                         curve: Curves.easeInOut,
//                         alignment: 0.5,
//                       );
//                     }
//                   });
//                 },
//                 hintText: "Reply to ${commentData.name}...",
//                 height: 50,
//               ),
//             ),
//           )
//         ]
//       ],
//     );
//   }

//   Widget _buildThreadedReplyItem(Widget replyWidget) {
//     return Stack(
//       children: [
//         Positioned(
//           left: 0,
//           top: -5,
//           child: Container(
//             width: 20,
//             height: 20,
//             decoration: BoxDecoration(
//               border: Border(
//                 left: BorderSide(color: Colors.grey[300]!, width: 1),
//                 bottom: BorderSide(color: Colors.grey[300]!, width: 1),
//               ),
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(12),
//               ),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(left: 36.0, bottom: 20),
//           child: replyWidget,
//         ),
//       ],
//     );
//   }

//   Widget _buildReplyComment({
//     required String id,
//     required String name,
//     required String date,
//     required String comment,
//     required String avatarUrl,
//     required String parentId,
//   }) {
//     // Check if it's Darlene to add the input box
//     final size = MediaQuery.of(context).size;
//     bool isLiked = _likedComments.contains(id);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CircleAvatar(
//               radius: 12,
//               backgroundImage: NetworkImage(avatarUrl),
//               backgroundColor: Colors.grey[200],
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   RichText(
//                     text: TextSpan(
//                       children: [
//                         TextSpan(
//                           text: name,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black,
//                             fontSize: 12,
//                           ),
//                         ),
//                         TextSpan(
//                           text: " • $date",
//                           style: TextStyle(
//                             color: Colors.grey[500],
//                             fontSize: 11,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     comment,
//                     textAlign: TextAlign.justify,
//                     style: commonTextStyle(
//                         size: size,
//                         fontSize: size.width * numD03,
//                         color: Colors.black,
//                         lineHeight: 2,
//                         fontWeight: FontWeight.normal),
//                   ),
//                   const SizedBox(height: 6),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.favorite_border,
//                               size: 12, color: Colors.grey[400]),
//                           const SizedBox(width: 4),
//                           Text(isLiked ? "51 likes" : "50 likes",
//                               style: TextStyle(
//                                   fontSize: 11, color: Colors.grey[500])),
//                           const SizedBox(width: 12),
//                           Icon(Icons.chat_bubble_outline,
//                               size: 12, color: Color(0xFFEF4444)),
//                           const SizedBox(width: 4),
//                           Text("0 reply",
//                               style: TextStyle(
//                                   fontSize: 11, color: Color(0xFFEF4444))),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           _buildActionIcon(
//                             isLiked
//                                 ? Image.asset("assets/icons/new_heartfill.png",
//                                     width: size.width * numD04,
//                                     height: size.width * numD04)
//                                 : Image.asset("assets/icons/news_heart.png",
//                                     width: size.width * numD04,
//                                     height: size.width * numD04),
//                             onTap: () {
//                               setState(() {
//                                 if (isLiked) {
//                                   _likedComments.remove(id);
//                                 } else {
//                                   _likedComments.add(id);
//                                 }
//                               });
//                             },
//                           ),
//                           const SizedBox(width: 8),
//                           _buildActionIcon(
//                               Image.asset("assets/icons/news_send1.png",
//                                   width: size.width * numD04,
//                                   height: size.width * numD04), onTap: () {
//                             Share.share('Check out this reply by $name');
//                           }),
//                           const SizedBox(width: 8),
//                           _buildActionIcon(
//                               Image.asset("assets/icons/news_message1.png",
//                                   width: size.width * numD04,
//                                   height: size.width * numD04), onTap: () {
//                             // Activate dummy reply
//                             setState(() {
//                               _replyingTo =
//                                   parentId; // Reply to parent thread usually
//                             });
//                           }),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildSimpleComment({
//     required String id,
//     required String name,
//     required String date,
//     required String comment,
//     required String avatarUrl,
//     required String likes,
//     required String replies,
//   }) {
//     final size = MediaQuery.of(context).size;
//     bool isLiked = _likedComments.contains(id);

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 24.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               CircleAvatar(
//                 radius: 18,
//                 backgroundImage: NetworkImage(avatarUrl),
//                 backgroundColor: Colors.grey[200],
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     RichText(
//                       text: TextSpan(
//                         children: [
//                           TextSpan(
//                             text: name,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black,
//                               fontSize: 13,
//                             ),
//                           ),
//                           TextSpan(
//                             text: " • $date",
//                             style: TextStyle(
//                               color: Colors.grey[500],
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       comment,
//                       style: commonTextStyle(
//                           size: size,
//                           fontSize: size.width * numD03,
//                           color: Colors.black,
//                           lineHeight: 2,
//                           fontWeight: FontWeight.normal),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.favorite_border,
//                                 size: 14, color: Colors.grey[400]),
//                             const SizedBox(width: 4),
//                             Text(likes,
//                                 style: TextStyle(
//                                     fontSize: 11, color: Colors.grey[500])),
//                             const SizedBox(width: 16),
//                             Icon(Icons.chat_bubble_outline,
//                                 size: 14, color: Color(0xFFEF4444)),
//                             const SizedBox(width: 4),
//                             Text(replies,
//                                 style: TextStyle(
//                                     fontSize: 11, color: Color(0xFFEF4444))),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             _buildActionIcon(
//                               isLiked
//                                   ? Image.asset(
//                                       "assets/icons/new_heartfill.png",
//                                       width: size.width * numD04,
//                                       height: size.width * numD04)
//                                   : Image.asset("assets/icons/news_heart.png",
//                                       width: size.width * numD04,
//                                       height: size.width * numD04),
//                               onTap: () {
//                                 setState(() {
//                                   if (isLiked) {
//                                     _likedComments.remove(id);
//                                   } else {
//                                     _likedComments.add(id);
//                                   }
//                                 });
//                               },
//                             ),
//                             const SizedBox(width: 8),
//                             _buildActionIcon(
//                                 Image.asset("assets/icons/news_send1.png",
//                                     width: size.width * numD04,
//                                     height: size.width * numD04), onTap: () {
//                               Share.share('Check out this comment by $name');
//                             }),
//                             const SizedBox(width: 8),
//                             _buildActionIcon(
//                                 Image.asset("assets/icons/news_message1.png",
//                                     width: size.width * numD04,
//                                     height: size.width * numD04), onTap: () {
//                               setState(() {
//                                 _replyingTo = id;
//                               });
//                             }),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           if (_replyingTo == id) ...[
//             Padding(
//               padding: const EdgeInsets.only(left: 50.0, top: 8, bottom: 8),
//               child: CommentInputWidget(
//                 controller: _replyController,
//                 onSend: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Reply sent (Dummy)")));
//                   _addReply(id, _replyController.text);
//                   _replyController.clear();
//                   setState(() {
//                     _replyingTo = null;
//                   });
//                 },
//                 hintText: "Reply to $name...",
//                 height: 50,
//               ),
//             )
//           ]
//         ],
//       ),
//     );
//   }
// }

// class CommentData {
//   String id;
//   String name;
//   String date;
//   String comment;
//   String avatarUrl;
//   int likes;
//   List<CommentData> replies;
//   bool isExpanded;

//   CommentData({
//     required this.id,
//     required this.name,
//     required this.date,
//     required this.comment,
//     required this.avatarUrl,
//     required this.likes,
//     this.replies = const [],
//     this.isExpanded = false,
//   });
// }
