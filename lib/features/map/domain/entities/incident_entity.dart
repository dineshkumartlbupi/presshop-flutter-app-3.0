import 'package:equatable/equatable.dart';
import 'package:presshop/features/map/domain/entities/geo_point.dart';

class IncidentEntity extends Equatable {
  final String id;
  final String markerType;
  final String type;
  final GeoPoint position;
  final String? address;
  final String? time;
  final String? image;
  final String? title;
  final String? description;
  final String? name;
  final String? rating;
  final String? specialization;
  final String? distance;
  final String? statusColor;
  final String? category;
  final String? alertType;

  const IncidentEntity({
    required this.id,
    required this.markerType,
    required this.type,
    required this.position,
    this.address,
    this.time,
    this.image,
    this.title,
    this.description,
    this.name,
    this.rating,
    this.specialization,
    this.distance,
    this.statusColor,
    this.category,
    this.alertType,
  });

  @override
  List<Object?> get props => [
        id,
        markerType,
        type,
        position,
        address,
        time,
        image,
        title,
        description,
        name,
        rating,
        specialization,
        distance,
        statusColor,
        category,
        alertType,
      ];
}
