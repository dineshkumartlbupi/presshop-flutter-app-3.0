import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import '../entities/user.dart';
import '../entities/avatar.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String username, String password);
  Future<Either<Failure, User>> socialLogin(String socialType, String socialId, String email, String name, String photoUrl);
  Future<Either<Failure, User>> register(Map<String, dynamic> data);
  Future<Either<Failure, bool>> sendOtp(Map<String, dynamic> data);
  Future<Either<Failure, User>> getProfile();
  Future<Either<Failure, bool>> checkAuthStatus();
  Future<Either<Failure, bool>> verifyOtp(Map<String, dynamic> data);
  Future<Either<Failure, User>> socialRegister(Map<String, dynamic> params);
  Future<Either<Failure, bool>> checkUserName(String userName);
  Future<Either<Failure, bool>> checkEmail(String email);
  Future<Either<Failure, bool>> checkPhone(String phone);
  Future<Either<Failure, List<Avatar>>> getAvatars();
  Future<Either<Failure, Map<String, dynamic>>> verifyReferralCode(String code);
  Future<Either<Failure, bool>> socialExists(Map<String, dynamic> params);
  Future<Either<Failure, bool>> forgotPassword(String email);
  Future<Either<Failure, bool>> verifyForgotPasswordOtp(String email, String otp);
  Future<Either<Failure, bool>> resetPassword(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, bool>> checkOnboardingStatus();
  Future<Either<Failure, void>> setOnboardingSeen();
}
