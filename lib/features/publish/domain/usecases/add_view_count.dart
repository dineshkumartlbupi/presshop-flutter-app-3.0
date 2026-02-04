import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/publish_repository.dart';

class AddViewCount implements UseCase<void, AddViewCountParams> {

  AddViewCount(this.repository);
  final PublishRepository repository;

  @override
  Future<Either<Failure, void>> call(AddViewCountParams params) async {
    return await repository.addViewCount(params.tutorialId);
  }
}

class AddViewCountParams extends Equatable {

  const AddViewCountParams({required this.tutorialId});
  final String tutorialId;

  @override
  List<Object> get props => [tutorialId];
}
