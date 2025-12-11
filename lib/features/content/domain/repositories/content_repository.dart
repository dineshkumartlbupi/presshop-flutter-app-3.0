import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import '../entities/content_item.dart';
import '../entities/hashtag.dart';

abstract class ContentRepository {
  Future<Either<Failure, List<ContentItem>>> getMyContent({int page = 1, int limit = 20, Map<String, dynamic> params = const {}});
  Future<Either<Failure, ContentItem>> publishContent(Map<String, dynamic> data);
  Future<Either<Failure, ContentItem>> saveDraft(Map<String, dynamic> data);
  Future<Either<Failure, ContentItem>> updateContent(String contentId, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteContent(String contentId);
  Future<Either<Failure, List<String>>> uploadMedia(List<String> filePaths);
  Future<Either<Failure, List<Hashtag>>> searchHashtags(String query);
  Future<Either<Failure, List<Hashtag>>> getTrendingHashtags();
  Future<Either<Failure, ContentItem>> getContentDetail(String contentId);
}
