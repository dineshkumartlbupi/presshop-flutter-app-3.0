import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/news/domain/entities/news.dart';
import 'package:presshop/features/news/domain/repositories/news_repository.dart';

class GetAggregatedNews
    implements UseCase<List<News>, GetAggregatedNewsParams> {
  final NewsRepository repository;

  GetAggregatedNews(this.repository);

  @override
  Future<Either<Failure, List<News>>> call(
      GetAggregatedNewsParams params) async {
    return await repository.getAggregatedNews(
      lat: params.lat,
      lng: params.lng,
      km: params.km,
      category: params.category,
      alertType: params.alertType,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetAggregatedNewsParams extends Equatable {
  final double lat;
  final double lng;
  final double km;
  final String category;
  final String? alertType;
  final int limit;
  final int offset;

  const GetAggregatedNewsParams({
    required this.lat,
    required this.lng,
    required this.km,
    this.category = "all",
    this.alertType,
    this.limit = 10,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [lat, lng, km, category, alertType, limit, offset];
}
