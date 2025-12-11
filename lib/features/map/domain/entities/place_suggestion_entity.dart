import 'package:equatable/equatable.dart';

class PlaceSuggestionEntity extends Equatable {
  final String description;
  final String placeId;

  const PlaceSuggestionEntity({
    required this.description,
    required this.placeId,
  });

  @override
  List<Object?> get props => [description, placeId];
}
