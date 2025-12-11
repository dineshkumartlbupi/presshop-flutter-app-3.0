import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/map/domain/entities/place_suggestion_entity.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';

class SearchPlaces implements UseCase<List<PlaceSuggestionEntity>, String> {
  final MapRepository repository;

  SearchPlaces(this.repository);

  @override
  Future<Either<Failure, List<PlaceSuggestionEntity>>> call(String query) async {
    return await repository.searchPlaces(query);
  }
}
