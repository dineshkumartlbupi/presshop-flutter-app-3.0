import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/content_item.dart';
import '../repositories/content_repository.dart';

class GetContentDetail implements UseCase<ContentItem, String> {
  final ContentRepository repository;

  GetContentDetail(this.repository);

  @override
  Future<Either<Failure, ContentItem>> call(String contentId) async {
    return await repository.getContentDetail(contentId);
  }
}
