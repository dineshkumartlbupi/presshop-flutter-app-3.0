import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/api/network_info.dart';
import 'package:presshop/core/utils/common_utils.dart';
import '../../domain/entities/profile_data.dart';
import '../../domain/entities/avatar.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import 'package:presshop/features/authentication/data/datasources/auth_local_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  final ProfileRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  ProfileData? _cachedProfile;

  @override
  Future<Either<Failure, ProfileData>> getProfile(
      {bool showLoader = true}) async {
    if (_cachedProfile != null && !showLoader) {
      return Right(_cachedProfile!);
    }

    if (await networkInfo.isConnected) {
      try {
        final userId = await localDataSource.getUserId();
        if (userId == null) {
          return const Left(CacheFailure(message: "User ID not found"));
        }
        final profileModel =
            await remoteDataSource.getProfile(userId, showLoader: showLoader);
        await localDataSource.cacheUser(profileModel.toJson());
        
        _cachedProfile = profileModel.toEntity().copyWith(
              profileImage: fixS3Url(profileModel.profileImage),
              avatar: fixS3Url(profileModel.avatar),
            );
        return Right(_cachedProfile!);
      } on Failure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      if (_cachedProfile != null) {
        return Right(_cachedProfile!);
      }
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ProfileData>> updateProfile(
      Map<String, dynamic> data) async {
    if (await networkInfo.isConnected) {
      try {
        final profileModel = await remoteDataSource.updateProfile(data);
        final profileEntity = profileModel.toEntity().copyWith(
              profileImage: fixS3Url(profileModel.profileImage),
              avatar: fixS3Url(profileModel.avatar),
            );
        _cachedProfile = profileEntity;
        return Right(profileEntity);
      } on Failure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(String imagePath) async {
    if (await networkInfo.isConnected) {
      try {
        final imageUrl = await remoteDataSource.uploadProfileImage(imagePath);
        return Right(imageUrl);
      } on Failure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
      String oldPassword, String newPassword) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.changePassword(oldPassword, newPassword);
        return const Right(null);
      } on Failure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> checkUserName(String username) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.checkUserName(username);
        return Right(result);
      } on Failure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Avatar>>> getAvatars() async {
    if (await networkInfo.isConnected) {
      try {
        final List<Avatar> avatars = await remoteDataSource.getAvatars();
        return Right(avatars);
      } on Failure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
