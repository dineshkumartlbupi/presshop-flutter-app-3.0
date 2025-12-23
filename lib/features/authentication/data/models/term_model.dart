class TermsResponse {
  final TermsData data;

  TermsResponse({required this.data});

  factory TermsResponse.fromJson(Map<String, dynamic> json) {
    return TermsResponse(
      data: TermsData.fromJson(json['data']),
    );
  }
}

class TermsData {
  final CmsItem privacyPolicy;
  final CmsItem termAndCond;

  TermsData({
    required this.privacyPolicy,
    required this.termAndCond,
  });

  factory TermsData.fromJson(Map<String, dynamic> json) {
    return TermsData(
      privacyPolicy: CmsItem.fromJson(json['privacyPolicy']),
      termAndCond: CmsItem.fromJson(json['termAndCond']),
    );
  }
}

class CmsItem {
  final String id;
  final String description;

  CmsItem({
    required this.id,
    required this.description,
  });

  factory CmsItem.fromJson(Map<String, dynamic> json) {
    return CmsItem(
      id: json['id'],
      description: json['description'],
    );
  }
}
