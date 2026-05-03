import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/network_info.dart';
import 'package:presshop/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:presshop/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:presshop/features/profile/domain/repositories/profile_repository.dart';

class MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockProfileRepository extends Mock implements ProfileRepository {}
