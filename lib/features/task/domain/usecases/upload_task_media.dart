import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/task/domain/repositories/task_repository.dart';

class UploadTaskMediaParams {
  final FormData data;
  final bool showLoader;

  UploadTaskMediaParams({required this.data, this.showLoader = true});
}

class UploadTaskMedia
    implements UseCase<Map<String, dynamic>, UploadTaskMediaParams> {
  final TaskRepository repository;

  UploadTaskMedia(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      UploadTaskMediaParams params) async {
    return await repository.uploadTaskMedia(params.data,
        showLoader: params.showLoader);
  }
}
