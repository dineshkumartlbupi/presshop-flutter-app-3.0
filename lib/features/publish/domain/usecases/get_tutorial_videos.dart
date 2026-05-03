import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../../data/models/tutorials_model.dart';
import '../repositories/tutorials_repository.dart';

class GetTutorialVideos
    implements UseCase<List<TutorialsModel>, GetTutorialVideosParams> {

  GetTutorialVideos(this.repository);
  final TutorialsRepository repository;

  @override
  Future<Either<Failure, List<TutorialsModel>>> call(
      GetTutorialVideosParams params) async {
    return await repository.getTutorials(
        params.category, params.offset, params.limit);
  }
}

class GetTutorialVideosParams extends Equatable {

  const GetTutorialVideosParams(
      {required this.category, required this.offset, required this.limit});
  final String category;
  final int offset;
  final int limit;

  @override
  List<Object> get props => [category, offset, limit];
}
