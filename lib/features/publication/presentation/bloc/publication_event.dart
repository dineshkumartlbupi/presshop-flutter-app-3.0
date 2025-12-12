import 'package:equatable/equatable.dart';

abstract class PublicationEvent extends Equatable {
  const PublicationEvent();

  @override
  List<Object> get props => [];
}

class LoadPublicationInitialData extends PublicationEvent {
  final String contentId;
  final String contentType;

  const LoadPublicationInitialData({required this.contentId, required this.contentType});

  @override
  List<Object> get props => [contentId, contentType];
}

class FilterPublicationTransactions extends PublicationEvent {
  final Map<String, dynamic> params;

  const FilterPublicationTransactions(this.params);

  @override
  List<Object> get props => [params];
}
