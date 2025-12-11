import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/feed.dart';
import '../repositories/feed_repository.dart';

class GetFeeds implements UseCase<List<Feed>, GetFeedsParams> {
  final FeedRepository repository;

  GetFeeds(this.repository);

  @override
  Future<Either<Failure, List<Feed>>> call(GetFeedsParams params) async {
    return await repository.getFeeds(params.params);
  }
}

class GetFeedsParams extends Equatable {
  final Map<String, dynamic> params;

  const GetFeedsParams({required this.params});

  @override
  List<Object> get props => [params];
}
