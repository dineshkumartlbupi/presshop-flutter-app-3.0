import 'package:google_maps_flutter/google_maps_flutter.dart';

class Incident {
  Incident({
    required this.id,
    required this.markerType,
    required this.position,
    this.type,
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
    this.author,
    this.date,
    this.soldCount,
    this.earnings,
    this.viewCount,
    this.isPublished,
    this.isMostViewed,
    this.likesCount,
    this.commentsCount,
    this.sharesCount,
    this.isLiked,
    this.mediaType,
    this.temperature,
    this.wind,
    this.heading,
    this.avatar,
    this.username,
  });

  factory Incident.fromMap(Map<String, dynamic> map) {
    final pos = map['position'] as Map<String, dynamic>;
    return Incident(
      id: map['id'],
      markerType: map['markerType'],
      type: map['type'],
      position: LatLng(pos['lat'], pos['lng']),
      address: map['location'],
      time: map['time'],
      image: map['image'],
      title: map['title'],
      description: map['description'],
      name: map['name'],
      rating: map['rating'],
      specialization: map['specialization'],
      distance: map['distance'],
      statusColor: map['statusColor'],
      category: map['category'],
      alertType: map['alertType'],
      author: map['author'],
      date: map['date'],
      soldCount: map['soldCount'],
      earnings: map['earnings']?.toDouble(),
      viewCount: map['viewCount'],
      isPublished: map['isPublished'],
      isMostViewed: map['isMostViewed'],
      likesCount: map['likesCount'],
      commentsCount: map['commentsCount'],
      sharesCount: map['sharesCount'],
      isLiked: map['isLiked'],
      mediaType: map['mediaType'],
      temperature: map['temperature'],
      wind: map['wind'],
      heading: map['heading'],
      avatar: map['avatar'],
      username: map['username'],
    );
  }

  factory Incident.fromJson(Map<String, dynamic> json) {
    double lat = 0.0;
    double lng = 0.0;

    if (json['position'] != null) {
      lat = (json['position']['lat'] ?? 0.0).toDouble();
      lng = (json['position']['lng'] ?? 0.0).toDouble();
    } else {
      lat = (json['lat'] ?? json['latitude'] ?? 0.0).toDouble();
      lng = (json['lng'] ?? json['longitude'] ?? 0.0).toDouble();
    }

    return Incident(
      id: (json['_id'] ?? json['id'] ?? DateTime.now().millisecondsSinceEpoch)
          .toString(),
      markerType: json['markerType'] ?? 'icon',
      type: json['type'] ?? 'accident',
      position: LatLng(lat, lng),
      address: json['address'] is String
          ? json['address'] as String
          : (json['location'] is String ? json['location'] as String : null),
      time: (json['createdAt'] ?? json['time'] ?? json['date'])?.toString(),
      image: json['image'],
      title: json['title'],
      description: json['description'] ?? json['message'],
      name: json['name'],
      rating: json['rating']?.toString(),
      specialization: json['specialization'],
      distance: json['distance']?.toString(),
      statusColor: json['statusColor'],
      category: json['category'],
      alertType: json['alertType'],
      author: json['author'],
      date: json['date'],
      soldCount: json['soldCount'],
      earnings: (json['earnings'] ?? 0.0).toDouble(),
      viewCount: json['viewCount'] ?? json['total_views'],
      isPublished: json['isPublished'],
      isMostViewed: json['isMostViewed'],
      likesCount: json['likesCount'] ?? json['likes'] ?? json['total_likes'],
      commentsCount: json['commentsCount'] ?? json['comments'],
      sharesCount: json['shares'] ?? json['shareCount'],
      isLiked: json['isLiked'] ?? json['is_liked'] ?? false,
      mediaType: json['mediaType'] ?? json['media_type'],
      temperature: json['temperature']?.toString(),
      wind: json['wind']?.toString(),
      heading: json['heading']?.toString(),
      avatar: json['avatar'] ?? json['user_avatar'] ?? json['user_image'],
      username: json['username'] ?? json['user_name'] ?? json['author_name'] ?? json['author'],
    );
  }
  final String id;
  final String markerType; // "icon", "content", "hopper"
  final String? type; // e.g. accident, fire (only for icon)
  final LatLng position;
  final String? address;
  final String? time;
  final String? image; // For content/hopper markers
  final String? title;
  final String? description;
  final String? name;
  final String? rating;
  final String? specialization;
  final String? distance;
  final String? statusColor;
  final String? category; // e.g. "Accident", "Crime", "Event"
  final String? alertType; // e.g. "Alert", "Info", "Warning"
  final String? author;
  final String? date;
  final int? soldCount;
  final double? earnings;
  final int? viewCount;
  final bool? isPublished;
  final bool? isMostViewed;
  final int? likesCount;
  final int? commentsCount;
  final int? sharesCount;
  final bool? isLiked;
  final String? mediaType;
  final String? temperature;
  final String? wind;
  final String? heading;
  final String? avatar;
  final String? username;

  Incident copyWith({
    String? id,
    String? markerType,
    String? type,
    LatLng? position,
    String? address,
    String? time,
    String? image,
    String? title,
    String? description,
    String? name,
    String? rating,
    String? specialization,
    String? distance,
    String? statusColor,
    String? category,
    String? alertType,
    String? author,
    String? date,
    int? soldCount,
    double? earnings,
    int? viewCount,
    bool? isPublished,
    bool? isMostViewed,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    bool? isLiked,
    String? mediaType,
    String? temperature,
    String? wind,
    String? heading,
    String? avatar,
    String? username,
  }) {
    return Incident(
      id: id ?? this.id,
      markerType: markerType ?? this.markerType,
      type: type ?? this.type,
      position: position ?? this.position,
      address: address ?? this.address,
      time: time ?? this.time,
      image: image ?? this.image,
      title: title ?? this.title,
      description: description ?? this.description,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      specialization: specialization ?? this.specialization,
      distance: distance ?? this.distance,
      statusColor: statusColor ?? this.statusColor,
      category: category ?? this.category,
      alertType: alertType ?? this.alertType,
      author: author ?? this.author,
      date: date ?? this.date,
      soldCount: soldCount ?? this.soldCount,
      earnings: earnings ?? this.earnings,
      viewCount: viewCount ?? this.viewCount,
      isPublished: isPublished ?? this.isPublished,
      isMostViewed: isMostViewed ?? this.isMostViewed,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isLiked: isLiked ?? this.isLiked,
      mediaType: mediaType ?? this.mediaType,
      temperature: temperature ?? this.temperature,
      wind: wind ?? this.wind,
      heading: heading ?? this.heading,
      avatar: avatar ?? this.avatar,
      username: username ?? this.username,
    );
  }
}

class DangerZone {
  DangerZone({
    required this.id,
    required this.name,
    required this.description,
    required this.points,
    this.icon,
  });
  final String id;
  final String name;
  final String description;
  final List<LatLng> points;
  final String? icon;
}

class Listing {
  Listing({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.imageUrl,
  });
  final String id;
  final String title;
  final String subtitle;
  final LatLng location;
  final String imageUrl;
}

class LocationModel {
  LocationModel({this.currentPosition, this.targetPosition, this.distance});
  LatLng? currentPosition;
  LatLng? targetPosition;
  double? distance;
}
