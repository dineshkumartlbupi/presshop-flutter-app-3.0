import 'package:flutter_test/flutter_test.dart';
import 'package:presshop/features/profile/data/models/avatar_model.dart';
import 'package:presshop/features/profile/domain/entities/avatar.dart';

void main() {
  const tAvatarModel = AvatarModel(
    id: '1',
    avatar: 'https://example.com/avatar.png',
  );

  group('AvatarModel', () {
    test('should be a subclass of Avatar entity', () async {
      // assert
      expect(tAvatarModel, isA<Avatar>());
    });

    test('fromJson should return a valid model when JSON has _id', () async {
      // arrange
      final Map<String, dynamic> jsonMap = {
        '_id': '1',
        'avatar': 'https://example.com/avatar.png',
      };
      // act
      final result = AvatarModel.fromJson(jsonMap);
      // assert
      expect(result, tAvatarModel);
    });

    test('fromJson should return a valid model when JSON has id', () async {
      // arrange
      final Map<String, dynamic> jsonMap = {
        'id': '1',
        'avatar': 'https://example.com/avatar.png',
      };
      // act
      final result = AvatarModel.fromJson(jsonMap);
      // assert
      expect(result, tAvatarModel);
    });

    test('toJson should return a JSON map containing the proper data',
        () async {
      // act
      final result = tAvatarModel.toJson();
      // assert
      final expectedMap = {
        '_id': '1',
        'avatar': 'https://example.com/avatar.png',
      };
      expect(result, expectedMap);
    });
  });
}
