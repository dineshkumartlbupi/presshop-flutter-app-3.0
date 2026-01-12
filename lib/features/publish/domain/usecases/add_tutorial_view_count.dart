import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/tutorials_repository.dart';

class AddTutorialViewCount
    implements UseCase<void, AddTutorialViewCountParams> {
  final TutorialsRepository repository;

  AddTutorialViewCount(this.repository);

  @override
  Future<Either<Failure, void>> call(AddTutorialViewCountParams params) async {
    return await repository.addViewCount(params.tutorialId);
  }
}

class AddTutorialViewCountParams extends Equatable {
  final String tutorialId;

  const AddTutorialViewCountParams({required this.tutorialId});

  @override
  List<Object> get props => [tutorialId];
}
