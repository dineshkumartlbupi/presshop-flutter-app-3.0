// import 'package:flutter/material.dart';

// class EventAlertCard extends StatelessWidget {
//   final String title;
//   final String description;
//   final String location;
//   final String dateTime;
//   final VoidCallback onAccept;

//   const EventAlertCard({
//     super.key,
//     required this.title,
//     required this.description,
//     required this.location,
//     required this.dateTime,
//     required this.onAccept,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 320,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontWeight: FontWeight.w700,
//               fontSize: 16,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             description,
//             style: const TextStyle(color: Colors.black54, fontSize: 14),
//           ),
//           const SizedBox(height: 12),
//           const Divider(height: 1, color: Colors.black12),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               const Icon(
//                 Icons.location_on_outlined,
//                 size: 18,
//                 color: Colors.black54,
//               ),
//               const SizedBox(width: 6),
//               Expanded(
//                 child: Text(
//                   location,
//                   style: const TextStyle(fontSize: 13, color: Colors.black87),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Row(
//             children: [
//               const Icon(Icons.access_time, size: 18, color: Colors.black54),
//               const SizedBox(width: 6),
//               Text(
//                 dateTime,
//                 style: const TextStyle(fontSize: 13, color: Colors.black87),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             width: double.infinity,
//             height: 48,
//             child: ElevatedButton(
//               onPressed: onAccept,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.redAccent,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 0,
//               ),
//               child: const Text(
//                 'Accept task',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 15,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
