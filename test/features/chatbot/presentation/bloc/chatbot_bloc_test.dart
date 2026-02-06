import 'package:bloc_test/bloc_test.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart' as df;
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/api/api_constant_new.dart';
import 'package:presshop/features/chatbot/presentation/bloc/chatbot_bloc.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDialogFlowtter extends Mock implements df.DialogFlowtter {}

class MockResponse extends Mock implements Response {}

// Register fallback values
class FakeQueryInput extends Fake implements df.QueryInput {}

void main() {
  late ChatbotBloc bloc;
  late MockApiClient mockApiClient;
  late MockDialogFlowtter mockDialogFlowtter;

  setUpAll(() {
    registerFallbackValue(FakeQueryInput());
  });

  setUp(() {
    mockApiClient = MockApiClient();
    mockDialogFlowtter = MockDialogFlowtter();
    bloc = ChatbotBloc(
      apiClient: mockApiClient,
      dialogFlowtter: mockDialogFlowtter,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('ChatbotBloc', () {
    test('initial state is ChatbotInitial', () {
      expect(bloc.state, ChatbotInitial());
    });

    group('FetchMessagesEvent', () {
      // final tChatList = [
      //   ChatModel(
      //       message: 'Hello',
      //       isUser: false,
      //       isNavigate: false,
      //       time: '2023-01-01')
      // ];
      final tResponseData = [
        {
          'message': 'Hello',
          'is_user': false,
          'is_navigate': false,
          'time': '2023-01-01'
        }
      ];

      blocTest<ChatbotBloc, ChatbotState>(
        'emits [ChatbotLoaded] when messages fetched successfully',
        build: () {
          final response = MockResponse();
          when(() => response.statusCode).thenReturn(200);
          when(() => response.data).thenReturn(tResponseData);
          when(() => mockApiClient.get(ApiConstantsNew.chat.getChatbotMessages))
              .thenAnswer((_) async => response);
          return bloc;
        },
        act: (bloc) => bloc.add(FetchMessagesEvent()),
        expect: () => [
          isA<ChatbotLoaded>()
              .having((s) => s.chatList.length, 'chatList length', 1)
        ],
      );

      blocTest<ChatbotBloc, ChatbotState>(
        'emits [ChatbotError] when fetch fails',
        build: () {
          final response = MockResponse();
          when(() => response.statusCode).thenReturn(400);
          when(() => mockApiClient.get(ApiConstantsNew.chat.getChatbotMessages))
              .thenAnswer((_) async => response);
          return bloc;
        },
        act: (bloc) => bloc.add(FetchMessagesEvent()),
        expect: () => [
          isA<ChatbotError>().having(
              (s) => s.message, 'message', contains('Failed to fetch messages'))
        ],
      );
    });

    group('SendMessageEvent', () {
      final tMessage = 'Hi';
      final tTime = '2023';

      blocTest<ChatbotBloc, ChatbotState>(
        'emits typing and then loaded with AI response',
        build: () {
          // Mock Add Message API (fire and forget in bloc, but good to mock)
          final response = MockResponse();
          when(() => response.statusCode).thenReturn(200);
          when(() => response.data).thenReturn({});
          when(() => mockApiClient.post(any(),
              data: any(named: 'data'),
              showLoader: false)).thenAnswer((_) async => response);

          // Mock DialogFlow
          final dfResponse = df.DetectIntentResponse(
              responseId: 'test_id',
              queryResult:
                  df.QueryResult(action: 'input.welcome', fulfillmentMessages: [
                df.Message(text: df.DialogText(text: ['Hello Human']))
              ]));
          when(() => mockDialogFlowtter.detectIntent(
                  queryInput: any(named: 'queryInput')))
              .thenAnswer((_) async => dfResponse);

          return bloc;
        },
        act: (bloc) =>
            bloc.add(SendMessageEvent(message: tMessage, time: tTime)),
        expect: () => [
          // 1. Add user message + typing
          isA<ChatbotLoaded>()
              .having((s) => s.chatList.last.message, 'user msg', tMessage)
              .having((s) => s.isTyping, 'isTyping', true),
          // 2. Add AI response + stop typing
          isA<ChatbotLoaded>()
              .having((s) => s.chatList.last.message, 'ai msg', 'Hello Human')
              .having((s) => s.isTyping, 'isTyping', false),
        ],
      );
    });
  });
}
