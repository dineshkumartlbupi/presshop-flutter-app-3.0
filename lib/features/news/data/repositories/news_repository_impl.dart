import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/exceptions.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/news/data/datasources/news_remote_datasource.dart';
import 'package:presshop/features/news/domain/entities/comment.dart';
import 'package:presshop/features/news/domain/entities/news.dart';
import 'package:presshop/features/news/domain/repositories/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;

  NewsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<News>>> getAggregatedNews({
    required double lat,
    required double lng,
    required double km,
    String category = "all",
  }) async {
    try {
      final result = await remoteDataSource.getAggregatedNews(
        lat: lat,
        lng: lng,
        km: km,
        category: category,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, News>> getNewsDetail(String id) async {
    try {
      final result = await remoteDataSource.getNewsDetail(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Comment>>> getComments(String contentId,
      {int limit = 15}) async {
    try {
      final result =
          await remoteDataSource.getComments(contentId, limit: limit);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
