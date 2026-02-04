import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/news/domain/entities/comment.dart';
import 'package:presshop/features/news/domain/repositories/news_repository.dart';

class GetComments implements UseCase<List<Comment>, GetCommentsParams> {

  GetComments(this.repository);
  final NewsRepository repository;

  @override
  Future<Either<Failure, List<Comment>>> call(GetCommentsParams params) async {
    return await repository.getComments(params.contentId, limit: params.limit);
  }
}

class GetCommentsParams extends Equatable {

  const GetCommentsParams({required this.contentId, this.limit = 15});
  final String contentId;
  final int limit;

  @override
  List<Object?> get props => [contentId, limit];
}
