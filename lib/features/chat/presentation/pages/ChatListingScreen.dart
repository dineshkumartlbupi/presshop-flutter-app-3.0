// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:presshop/core/di/injection_container.dart';
// import 'package:presshop/main.dart';
// import 'package:presshop/core/widgets/common_widgets.dart';
// import 'package:presshop/core/analytics/analytics_constants.dart';
// import 'package:presshop/core/analytics/analytics_mixin.dart';
// import 'package:presshop/core/core_export.dart';
// import 'package:presshop/core/api/api_client.dart';
// import 'package:presshop/core/widgets/common_app_bar.dart';
// import 'package:presshop/core/utils/shared_preferences.dart';
// import 'package:presshop/features/chat/presentation/bloc/chat_bloc.dart';
// import 'package:presshop/features/chat/presentation/bloc/chat_event.dart';
// import 'package:presshop/features/chat/presentation/bloc/chat_state.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:presshop/core/router/router_constants.dart';

// // ignore: must_be_immutable
// class ChatListingScreen extends StatefulWidget {
//   ChatListingScreen({super.key, required this.hideLeading});
//   bool hideLeading = false;

//   @override
//   State<ChatListingScreen> createState() => _ChatListingScreenState();
// }

// class _ChatListingScreenState extends State<ChatListingScreen>
//     with AnalyticsPageMixin {
//   late Size size;
//   final TextEditingController _searchController = TextEditingController();
//   String userId = "";
//   final ApiClient _apiClient = sl<ApiClient>();
//   List<AdminDetailModel> adminList = [];
//   List<AdminDetailModel> searchResult = [];

//   @override
//   void initState() {
//     super.initState();
//     userId = sharedPreferences!.getString(hopperIdKey) ?? "";
//     context.read<ChatBloc>().add(LoadChatListEvent());
//     callGetActiveAdmin();
//   }

//   @override
//   Widget build(BuildContext context) {
//     size = MediaQuery.of(context).size;
//     return Scaffold(
//       appBar: CommonAppBar(
//         elevation: 0,
//         hideLeading: widget.hideLeading,
//         title: Padding(
//           padding: EdgeInsets.only(
//               left: widget.hideLeading ? size.width * AppDimensions.numD04 : 0),
//           child: Text(
//             AppStrings.chatText,
//             style: TextStyle(
//                 color: Colors.black,
//                 fontWeight: FontWeight.bold,
//                 fontSize: size.width * AppDimensions.appBarHeadingFontSize),
//           ),
//         ),
//         centerTitle: false,
//         titleSpacing: 0,
//         size: size,
//         showActions: true,
//         leadingFxn: () => context.pop(),
//         actionWidget: [
//           InkWell(
//             onTap: () => context.goNamed(AppRoutes.dashboardName,
//                 extra: {'initialPosition': 2}),
//             child: Image.asset(
//               "${commonImagePath}rabbitLogo.png",
//               height: size.width * AppDimensions.numD07,
//               width: size.width * AppDimensions.numD07,
//             ),
//           ),
//           SizedBox(width: size.width * AppDimensions.numD04)
//         ],
//       ),
//       body: BlocBuilder<ChatBloc, ChatState>(
//         builder: (context, state) {
//           return Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: size.width * AppDimensions.numD05,
//               vertical: size.width * AppDimensions.numD03,
//             ),
//             child: ListView(
//               children: [
//                 searchWidget(),
//                 Padding(
//                   padding:
//                       EdgeInsets.only(top: size.width * AppDimensions.numD05),
//                   child: Text(
//                     AppStrings.chatWithPRESSHOPText.toUpperCase(),
//                     style: commonTextStyle(
//                         size: size,
//                         fontSize: size.width * AppDimensions.numD035,
//                         color: Colors.black,
//                         fontWeight: FontWeight.w500),
//                   ),
//                 ),
//                 SizedBox(height: size.width * AppDimensions.numD03),
//                 if (state.status == ChatStatus.loading)
//                   const Center(child: CircularProgressIndicator())
//                 else if (state.chatList.isEmpty)
//                   noChatWidget()
//                 else
//                   allChatListWidget(state.chatList),

//                 // Active Admin List
//                 Padding(
//                   padding: EdgeInsets.only(
//                       top: size.width * AppDimensions.numD05,
//                       bottom: size.width * AppDimensions.numD03),
//                   child: Text(
//                     "ACTIVE ADMINS",
//                     style: commonTextStyle(
//                         size: size,
//                         fontSize: size.width * AppDimensions.numD035,
//                         color: Colors.black,
//                         fontWeight: FontWeight.w500),
//                   ),
//                 ),
//                 activeAdminListWidget(),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget searchWidget() {
//     return TextFormField(
//       controller: _searchController,
//       decoration: InputDecoration(
//         fillColor: AppColorTheme.colorLightGrey,
//         isDense: true,
//         filled: true,
//         hintText: AppStrings.searchHintText,
//         border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(size.width * 0.03),
//             borderSide: BorderSide.none),
//         suffixIcon: Padding(
//           padding: EdgeInsets.all(size.width * 0.02),
//           child: Image.asset("${iconsPath}ic_search.png", color: Colors.black),
//         ),
//       ),
//       onChanged: (value) {
//         setState(() {
//           searchResult = adminList
//               .where((element) =>
//                   element.name.toLowerCase().contains(value.toLowerCase()))
//               .toList();
//         });
//       },
//     );
//   }

//   Widget allChatListWidget(List<Map<String, dynamic>> chatList) {
//     final filteredList = _searchController.text.isEmpty
//         ? chatList
//         : chatList.where((chat) {
//             final name = (chat['receiver_id'] == userId
//                     ? chat['sender_name']
//                     : chat['receiver_name'])
//                 .toString()
//                 .toLowerCase();
//             return name.contains(_searchController.text.toLowerCase());
//           }).toList();

//     return ListView.separated(
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       itemCount: filteredList.length,
//       separatorBuilder: (_, __) =>
//           SizedBox(height: size.width * AppDimensions.numD03),
//       itemBuilder: (context, index) {
//         final chat = filteredList[index];
//         final isMeSender = chat['sender_id'].toString() == userId;
//         final displayName =
//             isMeSender ? chat['receiver_name'] : chat['sender_name'];
//         final displayImage =
//             isMeSender ? chat['receiver_image'] : chat['sender_image'];
//         final lastMessage = chat['message'] ?? "";
//         final lastTime = chat['createdAt'] != null
//             ? DateFormat("hh:mm a").format(DateTime.parse(chat['createdAt']))
//             : "";

//         return InkWell(
//           onTap: () {
//             context.pushNamed(AppRoutes.conversationName, extra: {
//               'roomId': chat['room_id'],
//               'receiverId':
//                   isMeSender ? chat['receiver_id'] : chat['sender_id'],
//               'receiverName': displayName,
//               'receiverImage': displayImage,
//             });
//           },
//           child: Row(
//             children: [
//               CircleAvatar(
//                 radius: size.width * AppDimensions.numD08,
//                 backgroundImage: NetworkImage(displayImage),
//                 onBackgroundImageError: (_, __) {},
//                 child: displayImage.isEmpty
//                     ? Image.asset("${commonImagePath}rabbitLogo.png")
//                     : null,
//               ),
//               SizedBox(width: size.width * AppDimensions.numD03),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(displayName ?? "Unknown",
//                             style:
//                                 const TextStyle(fontWeight: FontWeight.bold)),
//                         Text(lastTime, style: const TextStyle(fontSize: 12)),
//                       ],
//                     ),
//                     Text(lastMessage,
//                         maxLines: 1, overflow: TextOverflow.ellipsis),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget activeAdminListWidget() {
//     final list = _searchController.text.isEmpty ? adminList : searchResult;
//     return ListView.separated(
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       itemCount: list.length,
//       separatorBuilder: (_, __) =>
//           SizedBox(height: size.width * AppDimensions.numD03),
//       itemBuilder: (context, index) {
//         final admin = list[index];
//         return InkWell(
//           onTap: () {
//             // Logic to create room or find existing room then navigate
//             _apiClient.post(ApiConstantsNew.chat.createRoom, data: {
//               'receiver_id': admin.id,
//               'receiver_name': admin.name,
//               'receiver_image': admin.profilePic,
//             }).then((response) {
//               if (response.statusCode == 200 || response.statusCode == 201) {
//                 final roomId = response.data['response']['room_id'];
//                 context.pushNamed(AppRoutes.conversationName, extra: {
//                   'roomId': roomId,
//                   'receiverId': admin.id,
//                   'receiverName': admin.name,
//                   'receiverImage': admin.profilePic,
//                 });
//               }
//             });
//           },
//           child: Row(
//             children: [
//               CircleAvatar(
//                 radius: size.width * AppDimensions.numD08,
//                 backgroundImage: NetworkImage(admin.profilePic),
//                 child: admin.profilePic.isEmpty
//                     ? Image.asset("${commonImagePath}rabbitLogo.png")
//                     : null,
//               ),
//               SizedBox(width: size.width * AppDimensions.numD03),
//               Text(admin.name.toCapitalized(),
//                   style: const TextStyle(fontWeight: FontWeight.bold)),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget noChatWidget() {
//     return Column(
//       children: [
//         SizedBox(height: size.width * AppDimensions.numD10),
//         Image.asset("${commonImagePath}rabbitLogo.png", height: 100),
//         const Text("No active chats",
//             style: TextStyle(fontWeight: FontWeight.bold)),
//       ],
//     );
//   }

//   Future<void> callGetActiveAdmin() async {
//     try {
//       final response = await _apiClient.get(ApiConstantsNew.misc.adminList);
//       var dataModel = response.data["data"] as List;
//       setState(() {
//         adminList = dataModel.map((e) => AdminDetailModel.fromJson(e)).toList();
//       });
//     } catch (e) {
//       debugPrint("Error fetching admins: $e");
//     }
//   }

//   @override
//   String get pageName => PageNames.chatListing;
// }
