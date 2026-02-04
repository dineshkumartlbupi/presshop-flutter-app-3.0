import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SocialLoginUser implements UseCase<User, SocialLoginParams> {

  SocialLoginUser(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(SocialLoginParams params) async {
    return await repository.socialLogin(
      params.socialType,
      params.socialId,
      params.email,
      params.name,
      params.photoUrl,
    );
  }
}

class SocialLoginParams extends Equatable {

  const SocialLoginParams({
    required this.socialType,
    required this.socialId,
    required this.email,
    required this.name,
    required this.photoUrl,
  });
  final String socialType;
  final String socialId;
  final String email;
  final String name;
  final String photoUrl;

  @override
  List<Object> get props => [socialType, socialId, email, name, photoUrl];
}
