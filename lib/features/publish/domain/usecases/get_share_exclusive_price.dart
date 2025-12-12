import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/publish_repository.dart';

class GetShareExclusivePrice implements UseCase<Map<String, String>, NoParams> {
  final PublishRepository repository;

  GetShareExclusivePrice(this.repository);

  @override
  Future<Either<Failure, Map<String, String>>> call(NoParams params) async {
    return await repository.getShareExclusivePrice();
  }
}
