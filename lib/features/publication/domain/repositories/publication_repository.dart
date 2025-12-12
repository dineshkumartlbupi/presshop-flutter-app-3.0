import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/media_house.dart';
import '../entities/publication_earning_stats.dart';
import '../entities/publication_transactions_result.dart';

abstract class PublicationRepository {
  Future<Either<Failure, PublicationEarningStats>> getEarningStats(String type);
  Future<Either<Failure, List<MediaHouse>>> getMediaHouses();
  Future<Either<Failure, PublicationTransactionsResult>> getPublicationTransactions(Map<String, dynamic> params);
}
