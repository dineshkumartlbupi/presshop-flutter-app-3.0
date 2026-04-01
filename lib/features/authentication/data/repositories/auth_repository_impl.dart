import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/api/network_info.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/main.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/avatar.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, User>> login(String username, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.login(username, password);
        debugPrint(
            "✅ AuthReposi tory: Login Success. Received Token: ${remoteUser.token?.substring(0, (remoteUser.token?.length ?? 0) > 10 ? 10 : (remoteUser.token?.length ?? 0))}...");
        await localDataSource.cacheToken(remoteUser.token ?? ""); // Cache token
        if (remoteUser.refreshToken != null) {
          debugPrint(
              "✅ AuthRepository: Received Refresh Token: ${remoteUser.refreshToken?.substring(0, (remoteUser.refreshToken?.length ?? 0) > 10 ? 10 : (remoteUser.refreshToken?.length ?? 0))}...");
          await localDataSource.cacheRefreshToken(remoteUser.refreshToken!);
        } else {
          debugPrint(
              "❌ AuthRepository: Refresh Token is NULL from Remote Data Source");
        }
        await localDataSource.setRememberMe(
            true); // Auto remember on explicit login? Or UI checkbox?
        // UI handles remember me separately usually.
        // But for getProfile sake, we need to cache fields.

        await _cacheUserDetails(remoteUser);

        return Right(remoteUser);
      } on Failure catch (failure) {
        return Left(failure); // If datasource throws specific failure
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  Future<void> _cacheUserDetails(User user) async {
    await localDataSource.cacheUser({
      'currency_symbol': user.currencySymbol,
      'referral_code': user.referralCode,
      'total_hopper_army': user.totalHopperArmy,
      // 'total_earnings': user./s,
      'avatar_id': user.avatarId,
      'avatar': user.avatar,
      '_id': user.id,
      // Map other fields as needed by AuthLocalDataSourceImpl
    });
  }

  @override
  Future<Either<Failure, User>> socialLogin(String socialType, String socialId,
      String email, String name, String photoUrl) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.socialLogin(
            socialType, socialId, email, name, photoUrl);
        await localDataSource.cacheToken(remoteUser.token ?? "");
        if (remoteUser.refreshToken != null) {
          await localDataSource.cacheRefreshToken(remoteUser.refreshToken!);
        }
        await localDataSource.setRememberMe(true);
        await _cacheUserDetails(remoteUser);
        return Right(remoteUser);
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
  Future<Either<Failure, User>> register(Map<String, dynamic> data) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.register(data);
        debugPrint(
            "✅ AuthRepository: Register Success. Received Token: ${remoteUser.token?.substring(0, (remoteUser.token?.length ?? 0) > 10 ? 10 : (remoteUser.token?.length ?? 0))}...");
        await localDataSource.cacheToken(remoteUser.token ?? "");
        if (remoteUser.refreshToken != null) {
          debugPrint(
              "✅ AuthRepository: Received Refresh Token: ${remoteUser.refreshToken?.substring(0, (remoteUser.refreshToken?.length ?? 0) > 10 ? 10 : (remoteUser.refreshToken?.length ?? 0))}...");
          await localDataSource.cacheRefreshToken(remoteUser.refreshToken!);
        }
        await localDataSource.setRememberMe(true);
        await _cacheUserDetails(remoteUser);
        return Right(remoteUser);
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
  Future<Either<Failure, bool>> sendOtp(Map<String, dynamic> data) async {
    debugPrint("📌 sendOtp() called");
    debugPrint("📦 Request Data: $data");

    if (await networkInfo.isConnected) {
      debugPrint("🌐 Internet Connected");

      try {
        debugPrint("➡️ Calling remoteDataSource.sendOtp");

        final result = await remoteDataSource.sendOtp(data);

        debugPrint("✅ API Success Response: $result");

        return Right(result);
      } on Failure catch (failure) {
        debugPrint("❌ Failure Caught: ${failure.message}");
        return Left(failure);
      } catch (e, stack) {
        debugPrint("🔥 Exception: $e");
        debugPrint("📍 StackTrace: $stack");
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      debugPrint("🚫 No Internet Connection");
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final userId = await localDataSource.getUserId();
        if (userId == null) {
          // If no user ID, we can't fetch profile.
          // This might happen if cache was cleared or never set properly.
          // For now, let's treat it as a failure so SplashBloc redirects to login.
          return const Left(CacheFailure(message: "User ID not found"));
        }
        final remoteUser = await remoteDataSource.getProfile(userId);
        // optionally update cache
        print('-----------------${remoteUser.currencySymbol}-----------------');

        sharedPreferences!.setString(SharedPreferencesKeys.currencySymbolKey,
                remoteUser.currencySymbol ?? "") ??
            "£";

        return Right(remoteUser);
      } on Failure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
      // Or return cached user if available
    }
  }

  @override
  Future<Either<Failure, bool>> checkAuthStatus() async {
    try {
      final rememberMe = await localDataSource.getRememberMe();
      final token = await localDataSource.getToken();

      debugPrint("🔍 AuthRepository: Checking Auth Status...");
      debugPrint("🔍 AuthRepository: RememberMe: $rememberMe");
      debugPrint(
          "🔍 AuthRepository: Token exists: ${token != null && token.isNotEmpty}");

      if (rememberMe && token != null && token.isNotEmpty) {
        return const Right(true);
      } else {
        return const Right(false);
      }
    } catch (e) {
      debugPrint("❌ AuthRepository: Error in checkAuthStatus: $e");
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyOtp(Map<String, dynamic> data) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.verifyOtp(data);
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
  Future<Either<Failure, User>> socialRegister(
      Map<String, dynamic> data) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.socialRegister(data);
        await localDataSource.cacheToken(remoteUser.token ?? "");
        if (remoteUser.refreshToken != null) {
          await localDataSource.cacheRefreshToken(remoteUser.refreshToken!);
        }
        await localDataSource.setRememberMe(true);
        await _cacheUserDetails(remoteUser);
        return Right(remoteUser);
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
  Future<Either<Failure, bool>> checkUserName(String userName) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.checkUserName(userName);
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
  Future<Either<Failure, bool>> checkEmail(String email) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.checkEmail(email);
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
  Future<Either<Failure, bool>> checkPhone(String phone) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.checkPhone(phone);
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
        final result = await remoteDataSource.getAvatars();
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
  Future<Either<Failure, Map<String, dynamic>>> verifyReferralCode(
      String code) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.verifyReferralCode(code);
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
  Future<Either<Failure, bool>> socialExists(
      Map<String, dynamic> params) async {
    try {
      final response = await remoteDataSource.socialExists(params);
      if (response) {
        return const Right(true);
      }
      return const Right(false);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, String>> forgotPassword(String email) async {
    if (await networkInfo.isConnected) {
      return await remoteDataSource.forgotPassword(email);
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> verifyForgotPasswordOtp(
      String email, String otp) async {
    if (await networkInfo.isConnected) {
      try {
        final result =
            await remoteDataSource.verifyForgotPasswordOtp(email, otp);
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
  Future<Either<Failure, bool>> resetPassword(
      String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.resetPassword(email, password);
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
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkOnboardingStatus() async {
    try {
      final result = await localDataSource.getOnboardingSeen();
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setOnboardingSeen() async {
    try {
      await localDataSource.setOnboardingSeen();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
