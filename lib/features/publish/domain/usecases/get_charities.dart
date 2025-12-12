import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/charity.dart';
import '../repositories/publish_repository.dart';

class GetCharities implements UseCase<List<Charity>, GetCharitiesParams> {
  final PublishRepository repository;

  GetCharities(this.repository);

  @override
  Future<Either<Failure, List<Charity>>> call(GetCharitiesParams params) async {
    return await repository.getCharities(params.offset, params.limit);
  }
}

class GetCharitiesParams extends Equatable {
  final int offset;
  final int limit;

  const GetCharitiesParams({required this.offset, required this.limit});

  @override
  List<Object> get props => [offset, limit];
}
