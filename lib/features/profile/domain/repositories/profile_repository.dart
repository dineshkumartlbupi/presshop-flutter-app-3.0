import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import '../entities/profile_data.dart';
import '../entities/avatar.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileData>> getProfile();
  Future<Either<Failure, ProfileData>> updateProfile(Map<String, dynamic> data);
  Future<Either<Failure, String>> uploadProfileImage(String imagePath);
  Future<Either<Failure, void>> changePassword(String oldPassword, String newPassword);
  Future<Either<Failure, bool>> checkUserName(String username);
  Future<Either<Failure, List<Avatar>>> getAvatars();
}
