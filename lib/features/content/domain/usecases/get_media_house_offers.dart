import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/task/data/models/manage_task_chat_model.dart';
import '../repositories/content_repository.dart';

class GetMediaHouseOffers
    implements UseCase<List<ManageTaskChatModel>, String> {

  GetMediaHouseOffers(this.repository);
  final ContentRepository repository;

  @override
  Future<Either<Failure, List<ManageTaskChatModel>>> call(
      String contentId) async {
    return await repository.getMediaHouseOffers(contentId);
  }
}
