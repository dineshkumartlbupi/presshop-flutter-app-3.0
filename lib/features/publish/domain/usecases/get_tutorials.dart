import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/tutorial.dart';
import '../repositories/publish_repository.dart';

class GetTutorials implements UseCase<List<Tutorial>, GetTutorialsParams> {
  final PublishRepository repository;

  GetTutorials(this.repository);

  @override
  Future<Either<Failure, List<Tutorial>>> call(GetTutorialsParams params) async {
    return await repository.getTutorials(params.category, params.offset, params.limit);
  }
}

class GetTutorialsParams extends Equatable {
  final String category;
  final int offset;
  final int limit;

  const GetTutorialsParams({required this.category, required this.offset, required this.limit});

  @override
  List<Object> get props => [category, offset, limit];
}
