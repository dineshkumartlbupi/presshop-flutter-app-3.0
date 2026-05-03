import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/publish_repository.dart';

class SubmitContent implements UseCase<void, SubmitContentParams> {

  SubmitContent(this.repository);
  final PublishRepository repository;

  @override
  Future<Either<Failure, void>> call(SubmitContentParams params) async {
    return await repository.submitContent(params.params, params.filePaths);
  }
}

class SubmitContentParams extends Equatable {

  const SubmitContentParams({required this.params, required this.filePaths});
  final Map<String, dynamic> params;
  final List<String> filePaths;

  @override
  List<Object> get props => [params, filePaths];
}
