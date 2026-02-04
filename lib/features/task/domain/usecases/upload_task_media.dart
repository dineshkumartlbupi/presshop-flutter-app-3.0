import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/task/domain/repositories/task_repository.dart';

class UploadTaskMedia implements UseCase<Map<String, dynamic>, FormData> {

  UploadTaskMedia(this.repository);
  final TaskRepository repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(FormData params) async {
    return await repository.uploadTaskMedia(params);
  }
}
