import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/media_house.dart';
import '../repositories/publication_repository.dart';

class GetMediaHouses implements UseCase<List<MediaHouse>, NoParams> {
  final PublicationRepository repository;

  GetMediaHouses(this.repository);

  @override
  Future<Either<Failure, List<MediaHouse>>> call(NoParams params) async {
    return await repository.getMediaHouses();
  }
}
