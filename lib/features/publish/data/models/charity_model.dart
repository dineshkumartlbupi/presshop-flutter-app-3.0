import '../../domain/entities/charity.dart';

class CharityModel extends Charity {
  const CharityModel({
    required super.id,
    required super.organisationNumber,
    required super.charityName,
    required super.charityImage,
    required super.country,
    required super.isSelectCharity,
  });

  factory CharityModel.fromJson(Map<String, dynamic> json) {
    return CharityModel(
      id: json['_id'] ?? "",
      organisationNumber: json['organisation_number'] ?? "",
      charityName: json['name'] ?? "",
      charityImage: json['logo'] ?? "",
      country: json['country'] ?? "",
      isSelectCharity: false,
    );
  }
}
