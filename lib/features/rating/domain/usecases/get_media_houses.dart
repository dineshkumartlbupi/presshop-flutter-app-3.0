import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/rating/domain/entities/media_house.dart';
import 'package:presshop/features/rating/domain/repositories/rating_repository.dart';

class GetMediaHouses implements UseCase<List<MediaHouse>, NoParams> {
  final RatingRepository repository;

  GetMediaHouses(this.repository);

  @override
  Future<Either<Failure, List<MediaHouse>>> call(NoParams params) async {
    return await repository.getMediaHouses();
  }
}
