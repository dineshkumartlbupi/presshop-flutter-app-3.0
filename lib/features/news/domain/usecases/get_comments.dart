import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/news/domain/entities/comment.dart';
import 'package:presshop/features/news/domain/repositories/news_repository.dart';

class GetComments implements UseCase<List<Comment>, GetCommentsParams> {
  final NewsRepository repository;

  GetComments(this.repository);

  @override
  Future<Either<Failure, List<Comment>>> call(GetCommentsParams params) async {
    return await repository.getComments(params.contentId, limit: params.limit);
  }
}

class GetCommentsParams extends Equatable {
  final String contentId;
  final int limit;

  const GetCommentsParams({required this.contentId, this.limit = 15});

  @override
  List<Object?> get props => [contentId, limit];
}
