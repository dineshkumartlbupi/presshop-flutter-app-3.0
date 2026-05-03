import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/rating/domain/entities/review.dart';
import 'package:presshop/features/rating/domain/repositories/rating_repository.dart';

class GetReviews implements UseCase<List<Review>, GetReviewsParams> {

  GetReviews(this.repository);
  final RatingRepository repository;

  @override
  Future<Either<Failure, List<Review>>> call(GetReviewsParams params) async {
    return await repository.getReviews(
      type: params.type,
      offset: params.offset,
      limit: params.limit,
      startDate: params.startDate,
      endDate: params.endDate,
      publicationId: params.publicationId,
      rating: params.rating,
      startRating: params.startRating,
      endRating: params.endRating,
    );
  }
}

class GetReviewsParams extends Equatable {

  const GetReviewsParams({
    required this.type,
    required this.offset,
    required this.limit,
    this.startDate,
    this.endDate,
    this.publicationId,
    this.rating,
    this.startRating,
    this.endRating,
  });
  final String type;
  final int offset;
  final int limit;
  final String? startDate;
  final String? endDate;
  final String? publicationId;
  final String? rating;
  final String? startRating;
  final String? endRating;

  @override
  List<Object?> get props => [
        type,
        offset,
        limit,
        startDate,
        endDate,
        publicationId,
        rating,
        startRating,
        endRating,
      ];
}
