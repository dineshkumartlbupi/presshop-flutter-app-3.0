import 'package:flutter_test/flutter_test.dart';
import 'package:presshop/features/chat/data/models/chat_models.dart';

void main() {
  group('ChatMessageModel', () {
    test('should return a valid model from JSON', () {
      // Arrange
      final Map<String, dynamic> json = {
        "_id": "1",
        "room_id": "room1",
        "message": "hello",
        "message_type": "text",
        "sender_id": "user1",
        "sender_type": "hopper",
        "sender_name": "John",
        "sender_image": "img",
        "createdAt": "2023-01-01T00:00:00Z",
        "read_status": "unread",
        "media": []
      };

      // Act
      final result = ChatMessageModel.fromJson(json, "user1");

      // Assert
      expect(result.id, "1");
      expect(result.isSender, true);
    });
  });
}
