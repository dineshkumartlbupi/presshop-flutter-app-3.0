import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/feed.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_data_source.dart';
import '../models/feed_model.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  FeedRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Feed>>> getFeeds(Map<String, dynamic> params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteData = await remoteDataSource.getFeeds(params);
        if (remoteData['code'] == 200) {
           final List<dynamic> list = remoteData['response'] ?? [];
           final feeds = list.map((e) => FeedModel.fromJson(e)).toList();
           return Right(feeds);
        } else {
           return Left(ServerFailure(message: remoteData['message'] ?? "Unknown Error"));
        }
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> toggleInteraction(String id, bool isLike, bool isFav, bool isEmoji, bool isClap) async {
    if (await networkInfo.isConnected) {
      try {
        Map<String, dynamic> params = {
          "content_id": id,
          "is_liked": isLike.toString(),
          "is_favourite": isFav.toString(),
          "is_emoji": isEmoji.toString(),
          "is_clap": isClap.toString(),
        };
        
        final success = await remoteDataSource.toggleInteraction(params);
        return Right(success);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
