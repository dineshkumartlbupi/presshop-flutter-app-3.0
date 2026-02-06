// import 'dart:async';
// import 'package:bloc_test/bloc_test.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:presshop/features/chat/presentation/bloc/chat_bloc.dart';
// import 'package:presshop/features/chat/presentation/bloc/chat_event.dart';
// import 'package:presshop/features/chat/presentation/bloc/chat_state.dart';
// import 'package:presshop/core/utils/shared_preferences.dart';
// import 'package:record/record.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:presshop/main.dart';

// class MockFirestore extends Mock implements FirebaseFirestore {}

// class MockFirebaseStorage extends Mock implements FirebaseStorage {}

// class MockAudioRecorder extends Mock implements AudioRecorder {}

// // class MockCollectionReference extends Mock
// //     implements CollectionReference<Map<String, dynamic>> {}

// // class MockDocumentReference extends Mock
// //     implements DocumentReference<Map<String, dynamic>> {}

// // class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

// // class MockQuerySnapshot extends Mock
// //     implements QuerySnapshot<Map<String, dynamic>> {}

// // class MockDocumentSnapshot extends Mock
// //     implements DocumentSnapshot<Map<String, dynamic>> {}

// void main() {
//   late ChatBloc chatBloc;
//   late MockFirestore mockFirestore;
//   late MockFirebaseStorage mockStorage;
//   late MockAudioRecorder mockAudioRecorder;

//   setUp(() async {
//     mockFirestore = MockFirestore();
//     mockStorage = MockFirebaseStorage();
//     mockAudioRecorder = MockAudioRecorder();

//     SharedPreferences.setMockInitialValues({
//       hopperIdKey: 'tester123',
//       firstNameKey: 'Test',
//       lastNameKey: 'User',
//     });
//     sharedPreferences = await SharedPreferences.getInstance();

//     when(() => mockAudioRecorder.dispose()).thenAnswer((_) async {});

//     registerFallbackValue(const EnterChatRoomEvent(
//         roomId: '', receiverId: '', receiverName: '', receiverImage: ''));
//     registerFallbackValue(
//         const SendMessageEvent(message: '', messageType: 'text'));

//     chatBloc = ChatBloc(
//       firestore: mockFirestore,
//       storage: mockStorage,
//       audioRecorder: mockAudioRecorder,
//     );
//   });

//   tearDown(() {
//     chatBloc.close();
//   });

//   group('ChatBloc Tests', () {
//     test('initial state is correct', () {
//       expect(chatBloc.state, const ChatState());
//     });

//     blocTest<ChatBloc, ChatState>(
//       'emits ChatStatus.loading when LoadChatListEvent is added',
//       build: () {
//         final mockCollection = MockCollectionReference();
//         final mockQuery = MockQuery();

//         when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
//         when(() => mockCollection.orderBy(any(),
//             descending: any(named: 'descending'))).thenReturn(mockQuery);
//         when(() => mockQuery.snapshots()).thenAnswer((_) => Stream.empty());

//         return chatBloc;
//       },
//       act: (bloc) => bloc.add(LoadChatListEvent()),
//       expect: () => [
//         isA<ChatState>().having((s) => s.status, 'status', ChatStatus.loading),
//       ],
//     );

//     blocTest<ChatBloc, ChatState>(
//       'emits ChatStatus.loaded when ChatListUpdatedEvent is added',
//       build: () => chatBloc,
//       act: (bloc) => bloc.add(const ChatListUpdatedEvent([])),
//       expect: () => [
//         isA<ChatState>()
//             .having((s) => s.status, 'status', ChatStatus.loaded)
//             .having((s) => s.chatList, 'chatList', []),
//       ],
//     );

//     blocTest<ChatBloc, ChatState>(
//       'emits ChatStatus.loading and loaded when EnterChatRoomEvent is added',
//       build: () {
//         final mockCollection = MockCollectionReference();
//         final mockDoc = MockDocumentReference();
//         final mockSubCollection = MockCollectionReference();
//         final mockQuery = MockQuery();
//         final mockUnreadQuery = MockQuery();
//         final mockUnreadSnapshot = MockQuerySnapshot();

//         when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
//         when(() => mockCollection.doc(any())).thenReturn(mockDoc);
//         when(() => mockDoc.collection(any())).thenReturn(mockSubCollection);
//         when(() => mockSubCollection.orderBy(any(),
//             descending: any(named: 'descending'))).thenReturn(mockQuery);
//         when(() => mockQuery.snapshots()).thenAnswer((_) => Stream.empty());

//         // Listen to typing
//         when(() => mockSubCollection.doc(any())).thenReturn(mockDoc);
//         when(() => mockDoc.snapshots()).thenAnswer((_) => Stream.empty());

//         // Mark as read logic
//         when(() => mockSubCollection.where(any(),
//             isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockUnreadQuery);
//         when(() => mockUnreadQuery.where(any(),
//             isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockUnreadQuery);
//         when(() => mockUnreadQuery.get())
//             .thenAnswer((_) async => mockUnreadSnapshot);
//         when(() => mockUnreadSnapshot.docs).thenReturn([]);

//         return chatBloc;
//       },
//       act: (bloc) => bloc.add(const EnterChatRoomEvent(
//         roomId: 'room1',
//         receiverId: 'user2',
//         receiverName: 'User Two',
//         receiverImage: 'image.jpg',
//       )),
//       expect: () => [
//         isA<ChatState>()
//             .having((s) => s.status, 'status', ChatStatus.loading)
//             .having((s) => s.currentRoomId, 'roomId', 'room1')
//             .having((s) => s.receiverId, 'receiverId', 'user2'),
//         isA<ChatState>().having((s) => s.status, 'status', ChatStatus.loaded),
//       ],
//     );

//     blocTest<ChatBloc, ChatState>(
//       'emits status sending then loaded when SendMessageEvent is added',
//       build: () {
//         final mockCollection = MockCollectionReference();
//         final mockDoc = MockDocumentReference();
//         final mockSubCollection = MockCollectionReference();
//         final mockMsgDoc = MockDocumentReference();

//         when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
//         when(() => mockCollection.doc(any())).thenReturn(mockDoc);
//         when(() => mockDoc.collection(any())).thenReturn(mockSubCollection);
//         when(() => mockSubCollection.doc()).thenReturn(mockMsgDoc);
//         when(() => mockMsgDoc.set(any())).thenAnswer((_) async {});
//         when(() => mockDoc.set(any(), any())).thenAnswer((_) async {});

//         return chatBloc;
//       },
//       seed: () => const ChatState(currentRoomId: 'room1', receiverId: 'user2'),
//       act: (bloc) => bloc
//           .add(const SendMessageEvent(message: 'Hello', messageType: 'text')),
//       expect: () => [
//         isA<ChatState>().having((s) => s.status, 'status', ChatStatus.sending),
//         isA<ChatState>().having((s) => s.status, 'status', ChatStatus.loaded),
//       ],
//     );

//     blocTest<ChatBloc, ChatState>(
//       'OtherUserTypingUpdatedEvent updates isTyping state',
//       build: () => chatBloc,
//       act: (bloc) => bloc.add(const OtherUserTypingUpdatedEvent(true)),
//       expect: () => [
//         isA<ChatState>().having((s) => s.isTyping, 'isTyping', true),
//       ],
//     );
//   });
// }
