import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/content_item.dart';
import '../repositories/content_repository.dart';

class SaveDraft implements UseCase<ContentItem, SaveDraftParams> {

  SaveDraft(this.repository);
  final ContentRepository repository;

  @override
  Future<Either<Failure, ContentItem>> call(SaveDraftParams params) async {
    return await repository.saveDraft(params.data);
  }
}

class SaveDraftParams {

  SaveDraftParams({required this.data});
  final Map<String, dynamic> data;
}
