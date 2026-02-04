import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/profile_data.dart';
import '../repositories/profile_repository.dart';

class GetProfileData implements UseCase<ProfileData, GetProfileParams> {
  GetProfileData(this.repository);
  final ProfileRepository repository;

  @override
  Future<Either<Failure, ProfileData>> call(GetProfileParams params) async {
    return await repository.getProfile(showLoader: params.showLoader);
  }
}

class GetProfileParams extends Equatable {

  const GetProfileParams({this.showLoader = true});
  final bool showLoader;

  @override
  List<Object?> get props => [showLoader];
}
