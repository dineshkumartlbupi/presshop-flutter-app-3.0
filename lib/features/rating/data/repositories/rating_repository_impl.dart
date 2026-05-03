import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/api/network_info.dart';
import 'package:presshop/features/rating/data/datasources/rating_remote_datasource.dart';
import 'package:presshop/features/rating/domain/entities/media_house.dart';
import 'package:presshop/features/rating/domain/entities/review.dart';
import 'package:presshop/features/rating/domain/repositories/rating_repository.dart';

import 'package:presshop/core/error/exceptions.dart';

class RatingRepositoryImpl implements RatingRepository {

  RatingRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  final RatingRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
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
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final Map<String, dynamic> params = {
          'limit': limit.toString(),
          'offset': offset.toString(),
          'type': type,
        };
        if (startDate != null) params['startdate'] = startDate;
        if (endDate != null) params['endDate'] = endDate;
        if (publicationId != null && publicationId.isNotEmpty) {
          params['publication'] = publicationId;
        }
        if (rating != null) params['rating'] = rating;
        if (startRating != null) params['startrating'] = startRating;
        if (endRating != null) params['endrating'] = endRating;

        final remoteReviews = await remoteDataSource.getReviews(params);
        return Right(remoteReviews);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, List<MediaHouse>>> getMediaHouses() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteMediaHouses = await remoteDataSource.getMediaHouses();
        // Map PublicationDataModel to MediaHouse entity
        final mediaHouses = remoteMediaHouses
            .map((model) => MediaHouse(
                id: model.id,
                name: model.companyName.isNotEmpty
                    ? model.companyName
                    : model.publicationName,
                profileImage: model.companyProfile))
            .toList();
        return Right(mediaHouses);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No Internet Connection'));
    }
  }
}
