import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/api/network_info.dart';
import '../../domain/repositories/tutorials_repository.dart';
import '../../data/datasources/tutorials_remote_datasource.dart';
import '../../data/models/tutorials_model.dart';
import '../../data/models/category_data_model.dart';

class TutorialsRepositoryImpl implements TutorialsRepository {
  final TutorialsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TutorialsRepositoryImpl(
      {required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<TutorialsModel>>> getTutorials(
      String category, int offset, int limit) async {
    try {
      final remoteTutorials =
          await remoteDataSource.getTutorials(category, offset, limit);
      return Right(remoteTutorials);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryDataModel>>> getCategories() async {
    try {
      final remoteCategories = await remoteDataSource.getCategories();
      return Right(remoteCategories);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addViewCount(String tutorialId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.addViewCount(tutorialId);
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
}
