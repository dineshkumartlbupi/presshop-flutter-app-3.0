import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/avatar.dart';
import '../repositories/profile_repository.dart';

class GetAvatars implements UseCase<List<Avatar>, NoParams> {
  GetAvatars(this.repository);
  final ProfileRepository repository;

  @override
  Future<Either<Failure, List<Avatar>>> call(NoParams params) async {
    return await repository.getAvatars();
  }
}
