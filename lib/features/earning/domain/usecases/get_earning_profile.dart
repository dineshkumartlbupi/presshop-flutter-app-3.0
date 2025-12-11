import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/earning_profile.dart';
import '../repositories/earning_repository.dart';

class GetEarningProfile implements UseCase<EarningProfile, GetEarningProfileParams> {
  final EarningRepository repository;

  GetEarningProfile(this.repository);

  @override
  Future<Either<Failure, EarningProfile>> call(GetEarningProfileParams params) async {
    return await repository.getEarningProfile(params.year, params.month);
  }
}

class GetEarningProfileParams extends Equatable {
  final String year;
  final String month;

  const GetEarningProfileParams({required this.year, required this.month});

  @override
  List<Object> get props => [year, month];
}
