import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/feed.dart';

abstract class FeedRepository {
  Future<Either<Failure, List<Feed>>> getFeeds(Map<String, dynamic> params);
  Future<Either<Failure, bool>> toggleInteraction(String id, bool isLike, bool isFav, bool isEmoji, bool isClap);
}
