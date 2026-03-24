import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/network_info.dart';
import 'package:presshop/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:presshop/features/chat/data/datasources/chat_socket_datasource.dart';
import 'package:presshop/features/chat/data/repositories/chat_repository_impl.dart';

class MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

class MockChatSocketDataSource extends Mock implements ChatSocketDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late ChatRepositoryImpl repository;
  late MockChatRemoteDataSource mockRemoteDataSource;
  late MockChatSocketDataSource mockSocketDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockChatRemoteDataSource();
    mockSocketDataSource = MockChatSocketDataSource();
    mockNetworkInfo = MockNetworkInfo();

    // Default mock for network info
    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);

    repository = ChatRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      socketDataSource: mockSocketDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('sendMessage', () {
    test(
        'should return ChatMessageModel and emit socket event when sending text',
        () async {
      // Act
      final result = await repository.sendMessage(
        roomId: 'room1',
        message: 'Hello',
        receiverId: 'user2',
        messageType: 'text',
        userId: 'user1',
      );

      // Assert
      expect(result.isRight(), true);
      verify(() => mockSocketDataSource.sendMessage(any())).called(1);
    });
  });
}
