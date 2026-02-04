import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SocialRegisterUser implements UseCase<User, SocialRegisterParams> {

  SocialRegisterUser(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(SocialRegisterParams params) async {
    return await repository.socialRegister(params.data);
  }
}

class SocialRegisterParams extends Equatable {

  const SocialRegisterParams({required this.data});
  final Map<String, dynamic> data;

  @override
  List<Object> get props => [data];
}
