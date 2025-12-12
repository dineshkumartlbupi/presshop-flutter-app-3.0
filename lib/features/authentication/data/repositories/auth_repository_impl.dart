import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/api/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/avatar.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> login(String username, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.login(username, password);
        await localDataSource.cacheToken(remoteUser.token ?? ""); // Cache token
        await localDataSource.setRememberMe(true); // Auto remember on explicit login? Or UI checkbox?
        // UI handles remember me separately usually. 
        // But for getProfile sake, we need to cache fields.
        
        await _cacheUserDetails(remoteUser);

        return Right(remoteUser);
      } on Failure catch (failure) {
        return Left(failure); // If datasource throws specific failure
      } catch(e) {
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
        'avatar_id': user.avatarId,
        'avatar': user.avatar,
        // Map other fields as needed by AuthLocalDataSourceImpl
      });
  }

  @override
  Future<Either<Failure, User>> socialLogin(String socialType, String socialId, String email, String name, String photoUrl) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.socialLogin(socialType, socialId, email, name, photoUrl);
        return Right(remoteUser);
      } on Failure catch (failure) {
        return Left(failure);
      } catch(e) {
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
        return Right(remoteUser);
      } on Failure catch (failure) {
        return Left(failure);
      } catch(e) {
         return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> sendOtp(Map<String, dynamic> data) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.sendOtp(data);
        return Right(result);
      } on Failure catch (failure) {
        return Left(failure);
      } catch(e) {
         return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.getProfile();
        // optionally update cache
        return Right(remoteUser);
      } on Failure catch (failure) {
        return Left(failure);
      } catch(e) {
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
       // Logic: Check if token exists and rememberMe is true.
       // Ideally we should also validate the token with backend, but getProfile does that.
       // Here we just check local state for Splash speed
       final rememberMe = await localDataSource.getRememberMe();
       final token = await localDataSource.getToken();

       if (rememberMe && token != null && token.isNotEmpty) {
         return const Right(true);
       } else {
         return const Right(false);
       }
    } catch (e) {
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
      } catch(e) {
         return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> socialRegister(Map<String, dynamic> data) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.socialRegister(data);
        await localDataSource.cacheToken(remoteUser.token ?? "");
         await localDataSource.setRememberMe(true);
        await _cacheUserDetails(remoteUser);
        return Right(remoteUser);
      } on Failure catch (failure) {
        return Left(failure);
      } catch(e) {
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
  Future<Either<Failure, Map<String, dynamic>>> verifyReferralCode(String code) async {
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
  Future<Either<Failure, bool>> socialExists(Map<String, dynamic> params) async {
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
  Future<Either<Failure, bool>> forgotPassword(String email) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.forgotPassword(email);
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
  Future<Either<Failure, bool>> verifyForgotPasswordOtp(String email, String otp) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.verifyForgotPasswordOtp(email, otp);
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
  Future<Either<Failure, bool>> resetPassword(String email, String password) async {
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
