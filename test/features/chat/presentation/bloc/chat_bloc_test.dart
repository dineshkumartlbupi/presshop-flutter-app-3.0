import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/chat/data/datasources/chat_socket_datasource.dart';
import 'package:presshop/features/chat/data/models/chat_models.dart';
import 'package:presshop/features/chat/domain/usecases/get_chat_list.dart';
import 'package:presshop/features/chat/domain/usecases/get_room_chat.dart';
import 'package:presshop/features/chat/domain/usecases/send_message.dart';
import 'package:presshop/features/chat/domain/usecases/upload_media.dart';
import 'package:presshop/features/chat/domain/usecases/update_typing_status.dart';
import 'package:presshop/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:presshop/features/chat/presentation/bloc/chat_event.dart';
import 'package:presshop/features/chat/presentation/bloc/chat_state.dart';
import 'package:presshop/main.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mocks
class MockGetChatListUseCase extends Mock implements GetChatListUseCase {}
class MockGetRoomChatUseCase extends Mock implements GetRoomChatUseCase {}
class MockSendMessageUseCase extends Mock implements SendMessageUseCase {}
class MockUploadMediaUseCase extends Mock implements UploadMediaUseCase {}
class MockUpdateTypingStatusUseCase extends Mock implements UpdateTypingStatusUseCase {}
class MockChatSocketDataSource extends Mock implements ChatSocketDataSource {}
class MockAudioRecorder extends Mock implements AudioRecorder {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

// Fallbacks for Mocktail any()
class FakeNoParams extends Fake implements NoParams {}
class FakeSendMessageParams extends Fake implements SendMessageParams {}
class FakeTypingStatusParams extends Fake implements TypingStatusParams {}

void main() {
  late ChatBloc bloc;
  late MockGetChatListUseCase mockGetChatListUseCase;
  late MockGetRoomChatUseCase mockGetRoomChatUseCase;
  late MockSendMessageUseCase mockSendMessageUseCase;
  late MockUploadMediaUseCase mockUploadMediaUseCase;
  late MockUpdateTypingStatusUseCase mockUpdateTypingStatusUseCase;
  late MockChatSocketDataSource mockChatSocketDataSource;
  late MockAudioRecorder mockAudioRecorder;
  late MockSharedPreferences mockSharedPreferences;

  setUpAll(() {
    registerFallbackValue(FakeNoParams());
    registerFallbackValue(FakeSendMessageParams());
    registerFallbackValue(FakeTypingStatusParams());
    registerFallbackValue(File(''));
  });

  setUp(() {
    mockGetChatListUseCase = MockGetChatListUseCase();
    mockGetRoomChatUseCase = MockGetRoomChatUseCase();
    mockSendMessageUseCase = MockSendMessageUseCase();
    mockUploadMediaUseCase = MockUploadMediaUseCase();
    mockUpdateTypingStatusUseCase = MockUpdateTypingStatusUseCase();
    mockChatSocketDataSource = MockChatSocketDataSource();
    mockAudioRecorder = MockAudioRecorder();
    mockSharedPreferences = MockSharedPreferences();

    sharedPreferences = mockSharedPreferences;

    // Default mocks for shared preferences
    when(() => mockSharedPreferences.getString(SharedPreferencesKeys.hopperIdKey)).thenReturn('user123');
    when(() => mockSharedPreferences.getString(SharedPreferencesKeys.firstNameKey)).thenReturn('John');
    when(() => mockSharedPreferences.getString(SharedPreferencesKeys.lastNameKey)).thenReturn('Doe');
    when(() => mockSharedPreferences.getString(SharedPreferencesKeys.avatarKey)).thenReturn('avatar.png');

    when(() => mockAudioRecorder.dispose()).thenAnswer((_) async => {});
    when(() => mockChatSocketDataSource.dispose()).thenAnswer((_) async => {});

    bloc = ChatBloc(
      getChatListUseCase: mockGetChatListUseCase,
      getRoomChatUseCase: mockGetRoomChatUseCase,
      sendMessageUseCase: mockSendMessageUseCase,
      uploadMediaUseCase: mockUploadMediaUseCase,
      updateTypingStatusUseCase: mockUpdateTypingStatusUseCase,
      chatSocketDataSource: mockChatSocketDataSource,
      audioRecorder: mockAudioRecorder,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('ChatBloc Tests', () {
    test('initial state should be ChatState()', () {
      expect(bloc.state, const ChatState());
    });

    blocTest<ChatBloc, ChatState>(
      'should emit [loading, loaded] when LoadChatListEvent is successful',
      build: () {
        when(() => mockGetChatListUseCase(any()))
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadChatListEvent()),
      expect: () => [
        isA<ChatState>().having((p) => p.status, 'status', ChatStatus.loading),
        isA<ChatState>().having((p) => p.status, 'status', ChatStatus.loaded),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'should emit [loading, failure] when LoadChatListEvent fails',
      build: () {
        when(() => mockGetChatListUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure(message: 'Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadChatListEvent()),
      expect: () => [
        isA<ChatState>().having((p) => p.status, 'status', ChatStatus.loading),
        isA<ChatState>().having((p) => p.status, 'status', ChatStatus.failure).having((p) => p.errorMessage, 'errorMessage', 'Error'),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'should emit loaded state with new message when SendMessageEvent is successful',
      build: () {
        final tMessage = ChatMessageModel(
          id: '1',
          roomId: 'room1',
          message: 'Hello',
          messageType: 'text',
          senderId: 'user123',
          senderType: 'hopper',
          senderName: 'John Doe',
          senderImage: 'avatar.png',
          createdAt: DateTime.now().toIso8601String(),
          readStatus: 'unread',
          media: [],
          isSender: true,
        );

        when(() => mockSendMessageUseCase(any()))
            .thenAnswer((_) async => Right(tMessage));
        return bloc;
      },
      seed: () => const ChatState(currentRoomId: 'room1', status: ChatStatus.loaded),
      act: (bloc) => bloc.add(const SendMessageEvent(message: 'Hello', messageType: 'text')),
      verify: (bloc) {
        verify(() => mockSendMessageUseCase(any())).called(1);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'should call UpdateTypingStatusUseCase when UpdateTypingStatusEvent is added',
      build: () {
        when(() => mockUpdateTypingStatusUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateTypingStatusEvent(roomId: 'room1', isTyping: true)),
      verify: (bloc) {
        verify(() => mockUpdateTypingStatusUseCase(any())).called(1);
      },
    );
  });
}
