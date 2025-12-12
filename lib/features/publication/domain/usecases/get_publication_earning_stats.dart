import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/publication_earning_stats.dart';
import '../repositories/publication_repository.dart';

class GetPublicationEarningStats implements UseCase<PublicationEarningStats, String> {
  final PublicationRepository repository;

  GetPublicationEarningStats(this.repository);

  @override
  Future<Either<Failure, PublicationEarningStats>> call(String type) async {
    return await repository.getEarningStats(type);
  }
}
