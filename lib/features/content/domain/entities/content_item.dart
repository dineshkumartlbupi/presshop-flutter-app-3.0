import 'package:equatable/equatable.dart';
import 'content_media.dart';

class ContentItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? mediaType; // photo, video, interview
  final List<String> mediaUrls;
  final List<ContentMedia> mediaList;
  final List<String> hashtags;
  final String? location;
  final String? latitude;
  final String? longitude;
  final String? price;
  final String status; //draft, published, pending, approved, rejected
  final String? categoryId;
  final DateTime? createdAt;
  final DateTime? publishedAt;
  final bool? isExclusive;
  final String? watermark;
  final int totalSold;
  final int totalOffer;
  final int totalView;
  final String? paidStatus;
  final int purchasedMediahouseCount;
  final String? saleStatus;
  final String? discountPercent;
  final String? mediaHouseName;
  final bool isPaidStatusToHopper;
  final String? userId;

  const ContentItem({
    required this.id,
    required this.title,
    required this.description,
    this.mediaType,
    required this.mediaUrls,
    this.mediaList = const [],
    required this.hashtags,
    this.location,
    this.latitude,
    this.longitude,
    this.price,
    required this.status,
    this.categoryId,
    this.createdAt,
    this.publishedAt,
    this.isExclusive,
    this.watermark,
    this.totalSold = 0,
    this.totalOffer = 0,
    this.totalView = 0,
    this.paidStatus,
    this.purchasedMediahouseCount = 0,
    this.saleStatus,
    this.discountPercent,
    this.mediaHouseName,
    this.isPaidStatusToHopper = false,
    this.userId,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        mediaType,
        mediaUrls,
        mediaList,
        hashtags,
        location,
        latitude,
        longitude,
        price,
        status,
        categoryId,
        createdAt,
        publishedAt,
        isExclusive,
        watermark,
        totalSold,
        totalOffer,
        totalView,
        paidStatus,
        purchasedMediahouseCount,
        saleStatus,
        discountPercent,
        mediaHouseName,
        isPaidStatusToHopper,
        userId,
      ];
}
