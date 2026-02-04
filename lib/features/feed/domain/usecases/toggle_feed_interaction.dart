import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/feed_repository.dart';

class ToggleFeedInteraction implements UseCase<bool, ToggleFeedInteractionParams> {

  ToggleFeedInteraction(this.repository);
  final FeedRepository repository;

  @override
  Future<Either<Failure, bool>> call(ToggleFeedInteractionParams params) async {
    return await repository.toggleInteraction(
      params.id, 
      params.isLike,
      params.isFav,
      params.isEmoji,
      params.isClap
    );
  }
}

class ToggleFeedInteractionParams extends Equatable {

  const ToggleFeedInteractionParams({
    required this.id,
    required this.isLike,
    required this.isFav,
    required this.isEmoji,
    required this.isClap,
  });
  final String id;
  final bool isLike;
  final bool isFav;
  final bool isEmoji;
  final bool isClap;

  @override
  List<Object> get props => [id, isLike, isFav, isEmoji, isClap];
}
