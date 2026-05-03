import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/rating/domain/entities/media_house.dart';
import 'package:presshop/features/rating/domain/entities/review.dart';

abstract class RatingRepository {
  Future<Either<Failure, List<Review>>> getReviews({
    required String type,
    required int offset,
    required int limit,
    String? startDate,
    String? endDate,
    String? publicationId,
    String? rating,
    String? startRating,
    String? endRating,
  });

  Future<Either<Failure, List<MediaHouse>>> getMediaHouses();
}
