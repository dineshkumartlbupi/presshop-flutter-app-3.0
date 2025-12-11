import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUser implements UseCase<User, RegisterParams> {
  final AuthRepository repository;

  RegisterUser(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.register(params.data);
  }
}

class RegisterParams extends Equatable {
  final Map<String, dynamic> data;

  const RegisterParams({required this.data});

  @override
  List<Object> get props => [data];
}
