import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class CheckUserName implements UseCase<bool, CheckUserNameParams> {

  CheckUserName(this.repository);
  final ProfileRepository repository;

  @override
  Future<Either<Failure, bool>> call(CheckUserNameParams params) async {
    return await repository.checkUserName(params.username);
  }
}

class CheckUserNameParams extends Equatable {

  const CheckUserNameParams({required this.username});
  final String username;

  @override
  List<Object?> get props => [username];
}
