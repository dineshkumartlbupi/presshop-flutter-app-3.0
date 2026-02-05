import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/commission.dart';
import '../repositories/earning_repository.dart';

class GetCommissions implements UseCase<List<Commission>, GetCommissionsParams> {

  GetCommissions(this.repository);
  final EarningRepository repository;

  @override
  Future<Either<Failure, List<Commission>>> call(GetCommissionsParams params) async {
    return await repository.getCommissions(params.params);
  }
}

class GetCommissionsParams extends Equatable {

  const GetCommissionsParams({required this.params});
  final Map<String, dynamic> params;

  @override
  List<Object> get props => [params];
}
