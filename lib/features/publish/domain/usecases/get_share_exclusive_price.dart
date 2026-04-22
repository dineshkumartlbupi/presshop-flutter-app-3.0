import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/publish_repository.dart';

class GetShareExclusivePriceParams {
  GetShareExclusivePriceParams({this.country});
  final String? country;
}

class GetShareExclusivePrice
    implements UseCase<Map<String, String>, GetShareExclusivePriceParams> {
  GetShareExclusivePrice(this.repository);
  final PublishRepository repository;

  @override
  Future<Either<Failure, Map<String, String>>> call(
      GetShareExclusivePriceParams params) async {
    return await repository.getShareExclusivePrice(params.country);
  }
}
