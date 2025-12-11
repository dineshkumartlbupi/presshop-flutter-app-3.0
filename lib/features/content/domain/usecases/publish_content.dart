import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/content_item.dart';
import '../repositories/content_repository.dart';

class PublishContent implements UseCase<ContentItem, PublishContentParams> {
  final ContentRepository repository;

  PublishContent(this.repository);

  @override
  Future<Either<Failure, ContentItem>> call(PublishContentParams params) async {
    return await repository.publishContent(params.data);
  }
}

class PublishContentParams {
  final Map<String, dynamic> data;

  PublishContentParams({required this.data});
}
