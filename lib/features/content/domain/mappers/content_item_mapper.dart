import '../../../../core/constants/string_constants_new.dart';
import '../../domain/entities/content_item.dart';
import '../../data/models/my_content_data_model.dart';
import '../../data/models/category_data_model.dart';

extension ContentItemMapper on ContentItem {
  MyContentData toMyContentData() {
    return MyContentData(
      id: id,
      title: title,
      textValue: description,
      time: createdAt,
      location: location,
      latitude: latitude,
      longitude: longitude,
      amount: price ?? "0",
      originalAmount: price ?? "0",
      status: status,
      soldStatus: "",
      paidStatus: paidStatus ? AppStrings.paidText : AppStrings.unPaidText,
      contentType: mediaType ?? "",
      dateTime: createdAt,
      isPaidStatusToHopper: isPaidStatusToHopper,
      exclusive: isExclusive ?? false,
      showVideo: false,
      audioDescription: "",
      audioDuration: "",
      contentMediaList: mediaList
          .map((m) => ContentMediaData(
              "", m.mediaUrl, m.mediaType, m.thumbnailUrl, m.watermarkUrl))
          .toList(),
      hashTagList: [],
      categoryData: CategoryDataModel(
        id: categoryData.id,
        name: categoryData.name,
        icon: categoryData.icon,
        percentage: categoryData.percentage,
        type: categoryData.type,
      ),
      completionPercent: "0",
      discountPercent: "0",
      leftPercent: 0,
      offerCount: totalOffer,
      mediaHouseName: "",
      categoryId: categoryId,
      contentView: totalView,
      purchasedMediahouseCount: purchasedMediahouseCount,
      totalEarning: totalSold,
      currency: currency,
      currencySymbol: currencySymbol,
    );
  }
}
