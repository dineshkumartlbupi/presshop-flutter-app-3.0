import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../../data/models/tutorials_model.dart';
import '../repositories/tutorials_repository.dart';

class GetTutorialVideos
    implements UseCase<List<TutorialsModel>, GetTutorialVideosParams> {
  final TutorialsRepository repository;

  GetTutorialVideos(this.repository);

  @override
  Future<Either<Failure, List<TutorialsModel>>> call(
      GetTutorialVideosParams params) async {
    return await repository.getTutorials(
        params.category, params.offset, params.limit);
  }
}

class GetTutorialVideosParams extends Equatable {
  final String category;
  final int offset;
  final int limit;

  const GetTutorialVideosParams(
      {required this.category, required this.offset, required this.limit});

  @override
  List<Object> get props => [category, offset, limit];
}
