import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/faq.dart';
import '../repositories/account_settings_repository.dart';

class GetFAQs implements UseCase<List<FAQ>, GetFAQsParams> {
  final AccountSettingsRepository repository;

  GetFAQs(this.repository);

  @override
  Future<Either<Failure, List<FAQ>>> call(GetFAQsParams params) async {
    return await repository.getFAQs(
        params.category, params.offset, params.limit);
  }
}

class GetFAQsParams extends Equatable {
  final String category;
  final int offset;
  final int limit;

  const GetFAQsParams({
    required this.category,
    required this.offset,
    required this.limit,
  });

  @override
  List<Object?> get props => [category, offset, limit];
}
