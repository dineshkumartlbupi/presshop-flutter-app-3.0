import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/api/network_info.dart';
import '../../domain/entities/content_item.dart';
import '../../domain/entities/hashtag.dart';
import 'package:presshop/features/task/data/models/manage_task_chat_model.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';
import '../../domain/repositories/content_repository.dart';
import '../datasources/content_remote_data_source.dart';

class ContentRepositoryImpl implements ContentRepository {

  ContentRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  final ContentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<ContentItem>>> getMyContent({
    int page = 1,
    int limit = 20,
    Map<String, dynamic> params = const {},
    bool showLoader = true,
    String type = 'my',
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteContent = await remoteDataSource.getMyContent(
          page: page,
          limit: limit,
          params: params,
          showLoader: showLoader,
          type: type,
        );
        return Right(remoteContent);
      } on Failure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ContentItem>> publishContent(
      Map<String, dynamic> data) async {
    if (await networkInfo.isConnected) {
      try {
        final content = await remoteDataSource.publishContent(data);
        return Right(content);
      } on Failure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ContentItem>> saveDraft(
      Map<String, dynamic> data) async {
    if (await networkInfo.isConnected) {
      try {
        final draft = await remoteDataSource.saveDraft(data);
        return Right(draft);
      } on Failure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ContentItem>> updateContent(
      String contentId, Map<String, dynamic> data) async {
    if (await networkInfo.isConnected) {
      try {
        final content = await remoteDataSource.updateContent(contentId, data);
        return Right(content);
      } on Failure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteContent(String contentId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteContent(contentId);
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

  @override
  Future<Either<Failure, List<String>>> uploadMedia(
      List<String> filePaths) async {
    if (await networkInfo.isConnected) {
      try {
        final urls = await remoteDataSource.uploadMedia(filePaths);
        return Right(urls);
      } on Failure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Hashtag>>> searchHashtags(String query) async {
    if (await networkInfo.isConnected) {
      try {
        final hashtags = await remoteDataSource.searchHashtags(query);
        return Right(hashtags);
      } on Failure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Hashtag>>> getTrendingHashtags() async {
    if (await networkInfo.isConnected) {
      try {
        final hashtags = await remoteDataSource.getTrendingHashtags();
        return Right(hashtags);
      } on Failure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ContentItem>> getContentDetail(
      String contentId) async {
    if (await networkInfo.isConnected) {
      try {
        final content = await remoteDataSource.getContentDetail(contentId);
        return Right(content);
      } on Failure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<ManageTaskChatModel>>> getMediaHouseOffers(
      String contentId) async {
    if (await networkInfo.isConnected) {
      try {
        final offers = await remoteDataSource.getMediaHouseOffers(contentId);
        return Right(offers);
      } on Failure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<EarningTransactionDetail>>>
      getContentTransactions(String contentId, int limit, int offset) async {
    if (await networkInfo.isConnected) {
      try {
        final transactions = await remoteDataSource.getContentTransactions(
            contentId, limit, offset);
        return Right(transactions);
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
