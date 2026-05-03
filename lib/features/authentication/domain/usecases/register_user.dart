import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUser implements UseCase<User, RegisterParams> {

  RegisterUser(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.register(params.data);
  }
}

class RegisterParams extends Equatable {

  const RegisterParams({required this.data});
  final Map<String, dynamic> data;

  @override
  List<Object> get props => [data];
}
