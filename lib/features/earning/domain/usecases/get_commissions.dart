import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/commission.dart';
import '../repositories/earning_repository.dart';

class GetCommissions implements UseCase<List<Commission>, GetCommissionsParams> {
  final EarningRepository repository;

  GetCommissions(this.repository);

  @override
  Future<Either<Failure, List<Commission>>> call(GetCommissionsParams params) async {
    return await repository.getCommissions(params.params);
  }
}

class GetCommissionsParams extends Equatable {
  final Map<String, dynamic> params;

  const GetCommissionsParams({required this.params});

  @override
  List<Object> get props => [params];
}
