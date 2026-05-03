import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/content_item.dart';
import '../repositories/content_repository.dart';

class GetContentDetail implements UseCase<ContentItem, GetContentDetailParams> {

  GetContentDetail(this.repository);
  final ContentRepository repository;

  @override
  Future<Either<Failure, ContentItem>> call(
      GetContentDetailParams params) async {
    return await repository.getContentDetail(params.contentId,
        showLoader: params.showLoader);
  }
}

class GetContentDetailParams extends Equatable {

  const GetContentDetailParams(this.contentId, {this.showLoader = true});
  final String contentId;
  final bool showLoader;

  @override
  List<Object?> get props => [contentId, showLoader];
}
