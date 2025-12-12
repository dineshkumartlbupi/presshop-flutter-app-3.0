import 'package:equatable/equatable.dart';

class Charity extends Equatable {
  final String id;
  final String organisationNumber;
  final String charityName;
  final String charityImage;
  final String country;
  final bool isSelectCharity;

  const Charity({
    required this.id,
    required this.organisationNumber,
    required this.charityName,
    required this.charityImage,
    required this.country,
    required this.isSelectCharity,
  });

  Charity copyWith({
    String? id,
    String? organisationNumber,
    String? charityName,
    String? charityImage,
    String? country,
    bool? isSelectCharity,
  }) {
    return Charity(
      id: id ?? this.id,
      organisationNumber: organisationNumber ?? this.organisationNumber,
      charityName: charityName ?? this.charityName,
      charityImage: charityImage ?? this.charityImage,
      country: country ?? this.country,
      isSelectCharity: isSelectCharity ?? this.isSelectCharity,
    );
  }

  @override
  List<Object?> get props => [id, organisationNumber, charityName, charityImage, country, isSelectCharity];
}
