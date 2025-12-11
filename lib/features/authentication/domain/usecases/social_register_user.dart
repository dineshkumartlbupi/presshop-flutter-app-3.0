import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SocialRegisterUser implements UseCase<User, SocialRegisterParams> {
  final AuthRepository repository;

  SocialRegisterUser(this.repository);

  @override
  Future<Either<Failure, User>> call(SocialRegisterParams params) async {
    return await repository.socialRegister(params.data);
  }
}

class SocialRegisterParams extends Equatable {
  final Map<String, dynamic> data;

  const SocialRegisterParams({required this.data});

  @override
  List<Object> get props => [data];
}
