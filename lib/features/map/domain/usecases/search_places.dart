import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';

class SearchPlaces implements UseCase<List<Map<String, dynamic>>, String> {

  SearchPlaces(this.repository);
  final MapRepository repository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(String query) async {
    return await repository.getPlaceSuggestions(query);
  }
}
