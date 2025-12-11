import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/profile_data.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileData implements UseCase<ProfileData, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfileData(this.repository);

  @override
  Future<Either<Failure, ProfileData>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(params.data);
  }
}

class UpdateProfileParams {
  final Map<String, dynamic> data;

  UpdateProfileParams({required this.data});
}
