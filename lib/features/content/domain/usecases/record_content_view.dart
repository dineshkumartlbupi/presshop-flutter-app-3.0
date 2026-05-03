import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/content_repository.dart';

class RecordContentView implements UseCase<void, RecordContentViewParams> {
  final ContentRepository repository;

  RecordContentView(this.repository);

  @override
  Future<Either<Failure, void>> call(RecordContentViewParams params) async {
    return await repository.recordContentView(
      contentId: params.contentId,
      userId: params.userId,
    );
  }
}

class RecordContentViewParams extends Equatable {
  final String contentId;
  final String userId;

  const RecordContentViewParams({required this.contentId, required this.userId});

  @override
  List<Object> get props => [contentId, userId];
}
