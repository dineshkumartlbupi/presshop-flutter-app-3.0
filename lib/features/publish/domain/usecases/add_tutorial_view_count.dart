import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/tutorials_repository.dart';

class AddTutorialViewCount
    implements UseCase<void, AddTutorialViewCountParams> {

  AddTutorialViewCount(this.repository);
  final TutorialsRepository repository;

  @override
  Future<Either<Failure, void>> call(AddTutorialViewCountParams params) async {
    return await repository.addViewCount(params.tutorialId);
  }
}

class AddTutorialViewCountParams extends Equatable {

  const AddTutorialViewCountParams({required this.tutorialId});
  final String tutorialId;

  @override
  List<Object> get props => [tutorialId];
}
