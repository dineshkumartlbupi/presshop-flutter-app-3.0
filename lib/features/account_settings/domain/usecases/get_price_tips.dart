import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/faq.dart';
import '../repositories/account_settings_repository.dart';

class GetPriceTips implements UseCase<List<FAQ>, GetPriceTipsParams> {

  GetPriceTips(this.repository);
  final AccountSettingsRepository repository;

  @override
  Future<Either<Failure, List<FAQ>>> call(GetPriceTipsParams params) async {
    return await repository.getPriceTips(
        params.category, params.offset, params.limit);
  }
}

class GetPriceTipsParams extends Equatable {

  const GetPriceTipsParams({
    required this.category,
    required this.offset,
    required this.limit,
  });
  final String category;
  final int offset;
  final int limit;

  @override
  List<Object?> get props => [category, offset, limit];
}
