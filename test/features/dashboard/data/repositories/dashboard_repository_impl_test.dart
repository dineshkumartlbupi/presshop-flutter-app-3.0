import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/network_info.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:presshop/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:presshop/features/dashboard/domain/entities/student_beans_info.dart';

import 'package:presshop/features/dashboard/data/models/admin_detail_model.dart';

class MockDashboardRemoteDataSource extends Mock
    implements DashboardRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late DashboardRepositoryImpl repository;
  late MockDashboardRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockDashboardRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = DashboardRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const tAdminModel = AdminDetailModel(
    id: '1',
    name: 'A',
    profilePic: '',
    lastMessageTime: '',
    lastMessage: '',
    roomId: '',
    senderId: '',
    receiverId: '',
    roomType: '',
  );
  final tAdminModels = [tAdminModel];

  group('getActiveAdmins', () {
    test('should return List<AdminDetail> when online and successful',
        () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getActiveAdmins())
          .thenAnswer((_) async => tAdminModels);

      // act
      final result = await repository.getActiveAdmins();

      // assert
      expect(result, Right(tAdminModels));
      verify(() => mockRemoteDataSource.getActiveAdmins());
    });

    test('should return NetworkFailure when offline', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.getActiveAdmins();

      // assert
      expect(result, Left(NetworkFailure()));
      verifyNever(() => mockRemoteDataSource.getActiveAdmins());
    });
  });

  group('checkStudentBeans', () {
    test(
        'should return StudentBeansInfo(shouldShow: true) when API data matches criteria',
        () async {
      // arrange
      final tResponse = {
        "code": 200,
        "userData": {
          "source": {
            "type": "studentbeans",
            "is_opened": false,
            "is_clicked": false,
            "heading": "Success",
            "description": "Desc"
          }
        }
      };
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.checkStudentBeans())
          .thenAnswer((_) async => tResponse);

      // act
      final result = await repository.checkStudentBeans();

      // assert
      expect(
          result,
          const Right(StudentBeansInfo(
            shouldShow: true,
            heading: "Success",
            description: "Desc",
          )));
    });

    test(
        'should return StudentBeansInfo(shouldShow: false) when already opened',
        () async {
      // arrange
      final tResponse = {
        "code": 200,
        "userData": {
          "source": {
            "type": "studentbeans",
            "is_opened": true,
            "is_clicked": false
          }
        }
      };
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.checkStudentBeans())
          .thenAnswer((_) async => tResponse);

      // act
      final result = await repository.checkStudentBeans();

      // assert
      expect(result, const Right(StudentBeansInfo(shouldShow: false)));
    });
  });
}
