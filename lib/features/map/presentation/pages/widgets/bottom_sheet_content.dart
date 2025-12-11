// import 'package:flutter/material.dart';
// import 'package:map/map/models/marker_model.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class BottomSheetContent extends StatelessWidget {
//   final ScrollController scrollController;
//   final List<Listing> items;
//   final ValueChanged<Listing> onItemTap;

//   const BottomSheetContent({
//     super.key,
//     required this.scrollController,
//     required this.items,
//     required this.onItemTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//       ),
//       child: ListView.builder(
//         controller: scrollController,
//         itemCount: items.length + 1,
//         itemBuilder: (context, index) {
//           if (index == 0) {
//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               child: Center(
//                 child: Container(
//                   width: 40,
//                   height: 5,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ),
//             );
//           }
//           final listing = items[index - 1];
//           return ListTile(
//             onTap: () => onItemTap(listing),
//             leading: ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: CachedNetworkImage(
//                 imageUrl: listing.imageUrl,
//                 width: 56,
//                 height: 56,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             title: Text(listing.title),
//             subtitle: Text(listing.subtitle),
//             trailing: const Icon(Icons.chevron_right),
//           );
//         },
//       ),
//     );
//   }
// }
