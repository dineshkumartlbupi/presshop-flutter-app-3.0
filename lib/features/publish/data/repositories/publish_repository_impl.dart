import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/api/network_info.dart';
import '../../domain/entities/content_category.dart';
import '../../domain/entities/charity.dart';
import '../../domain/entities/tutorial.dart';
import '../../domain/repositories/publish_repository.dart';
import '../datasources/publish_remote_data_source.dart';

class PublishRepositoryImpl implements PublishRepository {
  final PublishRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PublishRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ContentCategory>>> getCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final categories = await remoteDataSource.getContentCategories();
        return Right(categories);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<ContentCategory>>> getTutorialCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final categories = await remoteDataSource.getTutorialCategories();
        return Right(categories);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
  
  // Helper for tutorials category if needed, but interface only has getCategories.
  // I might need to distinguish. 
  // Let's assume getCategories is for Content Submission (main feature).
  // If I need tutorial categories, I should add it to interface or use same if types align.
  // I will add `getTutorialCategories` to interface in next edit if needed.

  @override
  Future<Either<Failure, List<Charity>>> getCharities(int offset, int limit) async {
    if (await networkInfo.isConnected) {
      try {
        final charities = await remoteDataSource.getCharities(offset, limit);
        return Right(charities);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Tutorial>>> getTutorials(String category, int offset, int limit) async {
    if (await networkInfo.isConnected) {
      try {
        final tutorials = await remoteDataSource.getTutorials(category, offset, limit);
        return Right(tutorials);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addViewCount(String tutorialId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.addViewCount(tutorialId);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> getShareExclusivePrice() async {
    if (await networkInfo.isConnected) {
      try {
        final prices = await remoteDataSource.getShareExclusivePrice();
        return Right(prices);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
