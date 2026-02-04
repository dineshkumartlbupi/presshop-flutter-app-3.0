import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/feed.dart';
import '../repositories/feed_repository.dart';

class GetFeeds implements UseCase<List<Feed>, GetFeedsParams> {

  GetFeeds(this.repository);
  final FeedRepository repository;

  @override
  Future<Either<Failure, List<Feed>>> call(GetFeedsParams params) async {
    return await repository.getFeeds(params.params);
  }
}

class GetFeedsParams extends Equatable {

  const GetFeedsParams({required this.params});
  final Map<String, dynamic> params;

  @override
  List<Object> get props => [params];
}
