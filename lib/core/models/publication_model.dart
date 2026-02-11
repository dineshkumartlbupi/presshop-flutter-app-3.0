class PublicationDataModel {
  PublicationDataModel.fromJson(Map<String, dynamic> json) {
    id = json["_id"] ?? "";
    companyName = json['AppStrings.companyName'] ?? json['company_name'] ?? '';

    String first = json['firstName'] ?? json['first_name'] ?? '';
    String last = json['lastName'] ?? json['last_name'] ?? '';
    publicationName = json["full_name"] ?? "$first $last".trim();

    role = json["role"] ?? "";
    status = json["status"] ?? "";
    companyProfile = json['profile_image'] ?? json['companyProfile'] ?? '';
  }
  String id = "";
  String publicationName = "";
  String companyName = "";
  String role = "";
  String companyProfile = "";
  String status = "";
}
