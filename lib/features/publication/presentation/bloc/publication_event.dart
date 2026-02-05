import 'package:equatable/equatable.dart';

abstract class PublicationEvent extends Equatable {
  const PublicationEvent();

  @override
  List<Object> get props => [];
}

class LoadPublicationInitialData extends PublicationEvent {

  const LoadPublicationInitialData({required this.contentId, required this.contentType});
  final String contentId;
  final String contentType;

  @override
  List<Object> get props => [contentId, contentType];
}

class FilterPublicationTransactions extends PublicationEvent {

  const FilterPublicationTransactions(this.params);
  final Map<String, dynamic> params;

  @override
  List<Object> get props => [params];
}
