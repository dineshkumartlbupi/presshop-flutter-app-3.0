import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/content_item.dart';
import '../repositories/content_repository.dart';

class GetMyContent implements UseCase<List<ContentItem>, GetMyContentParams> {
  final ContentRepository repository;

  GetMyContent(this.repository);

  @override
  Future<Either<Failure, List<ContentItem>>> call(GetMyContentParams params) async {
    return await repository.getMyContent(page: params.page, limit: params.limit, params: params.params);
  }
}

class GetMyContentParams {
  final int page;
  final int limit;
  final Map<String, dynamic> params;

  GetMyContentParams({this.page = 1, this.limit = 20, this.params = const {}});
}
