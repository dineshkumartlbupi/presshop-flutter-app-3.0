import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/content_item.dart';
import '../repositories/content_repository.dart';

class GetContentDetail implements UseCase<ContentItem, GetContentDetailParams> {
  final ContentRepository repository;

  GetContentDetail(this.repository);

  @override
  Future<Either<Failure, ContentItem>> call(
      GetContentDetailParams params) async {
    return await repository.getContentDetail(params.contentId,
        showLoader: params.showLoader);
  }
}

class GetContentDetailParams extends Equatable {
  final String contentId;
  final bool showLoader;

  const GetContentDetailParams(this.contentId, {this.showLoader = true});

  @override
  List<Object?> get props => [contentId, showLoader];
}
