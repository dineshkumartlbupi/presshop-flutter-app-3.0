import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/task/data/models/manage_task_chat_model.dart';
import '../repositories/content_repository.dart';

class GetMediaHouseOffers
    implements UseCase<List<ManageTaskChatModel>, GetMediaHouseOffersParams> {
  final ContentRepository repository;

  GetMediaHouseOffers(this.repository);

  @override
  Future<Either<Failure, List<ManageTaskChatModel>>> call(
      GetMediaHouseOffersParams params) async {
    return await repository.getMediaHouseOffers(params.contentId,
        showLoader: params.showLoader);
  }
}

class GetMediaHouseOffersParams extends Equatable {
  final String contentId;
  final bool showLoader;

  const GetMediaHouseOffersParams(this.contentId, {this.showLoader = true});

  @override
  List<Object?> get props => [contentId, showLoader];
}
