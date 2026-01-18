import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/news/domain/entities/comment.dart';
import 'package:presshop/features/news/domain/entities/news.dart';

abstract class NewsRepository {
  Future<Either<Failure, List<News>>> getAggregatedNews({
    required double lat,
    required double lng,
    required double km,
    String category = "all",
    String? alertType,
    int limit = 10,
    int offset = 0,
  });

  Future<Either<Failure, News>> getNewsDetail(String id);

  Future<Either<Failure, List<Comment>>> getComments(String contentId,
      {int limit = 15});
}
