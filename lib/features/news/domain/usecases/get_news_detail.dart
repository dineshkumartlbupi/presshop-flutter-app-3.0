import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/news/domain/entities/news.dart';
import 'package:presshop/features/news/domain/repositories/news_repository.dart';

class GetNewsDetail implements UseCase<News, GetNewsDetailParams> {
  final NewsRepository repository;

  GetNewsDetail(this.repository);

  @override
  Future<Either<Failure, News>> call(GetNewsDetailParams params) async {
    return await repository.getNewsDetail(params.id);
  }
}

class GetNewsDetailParams extends Equatable {
  final String id;

  const GetNewsDetailParams({required this.id});

  @override
  List<Object?> get props => [id];
}
