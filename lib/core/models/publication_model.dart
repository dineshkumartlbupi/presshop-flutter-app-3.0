
/// Publication List
class PublicationDataModel {
  String id = "";
  String publicationName = "";
  String companyName = "";
  String role = "";
  String companyProfile = "";
  String status = "";

  PublicationDataModel.fromJson(Map<String, dynamic> json) {
    id = json["_id"] ?? "";
    companyName = json['company_name'] ?? '';
    publicationName = json["full_name"] ?? "";
    role = json["role"] ?? "";
    status = json["status"] ?? "";
    companyProfile = json['profile_image'] ?? '';
  }
}
