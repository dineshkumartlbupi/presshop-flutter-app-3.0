import '../../domain/entities/content_item.dart';
import '../../data/models/my_content_data_model.dart';
import '../../presentation/pages/my_draft_screen.dart'; // For ContentMediaData

extension ContentItemMapper on ContentItem {
  MyContentData toMyContentData() {
    return MyContentData(
      id: id,
      title: title,
      textValue: description,
      time: createdAt?.toIso8601String() ?? "",
      location: location ?? "",
      latitude: latitude ?? "0.0",
      longitude: longitude ?? "0.0",
      amount: price ?? "0",
      originalAmount: price ?? "0",
      status: status,
      soldStatus: saleStatus ?? "",
      paidStatus: paidStatus ?? "",
      contentType: mediaType ?? "",
      dateTime: createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      isPaidStatusToHopper: isPaidStatusToHopper,
      exclusive: isExclusive ?? false,
      showVideo: false,
      audioDescription: "",
      
      contentMediaList: mediaList.map((m) => ContentMediaData(
        "", // id
        m.mediaUrl,
        m.mediaType,
        m.thumbnailUrl ?? "",
        m.watermarkUrl ?? ""
      )).toList(), 

      hashTagList: [],
      categoryData: null,
      completionPercent: "0",
      discountPercent: discountPercent ?? "0",
      leftPercent: 0,
      offerCount: totalOffer,
      mediaHouseName: mediaHouseName ?? "",
      categoryId: categoryId ?? "",
      contentView: totalView,
      purchasedMediahouseCount: purchasedMediahouseCount,
      totalEarning: totalSold.toString(),
    );
  }
}
