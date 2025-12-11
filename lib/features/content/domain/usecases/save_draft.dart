import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/content_item.dart';
import '../repositories/content_repository.dart';

class SaveDraft implements UseCase<ContentItem, SaveDraftParams> {
  final ContentRepository repository;

  SaveDraft(this.repository);

  @override
  Future<Either<Failure, ContentItem>> call(SaveDraftParams params) async {
    return await repository.saveDraft(params.data);
  }
}

class SaveDraftParams {
  final Map<String, dynamic> data;

  SaveDraftParams({required this.data});
}
