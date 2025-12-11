import '../../domain/entities/admin_contact_info.dart';

class AdminContactInfoModel extends AdminContactInfo {
  const AdminContactInfoModel({required super.email});

  factory AdminContactInfoModel.fromJson(Map<String, dynamic> json) {
    return AdminContactInfoModel(
      email: json['data'] != null ? json['data']['email'] ?? '' : '',
    );
  }
}
