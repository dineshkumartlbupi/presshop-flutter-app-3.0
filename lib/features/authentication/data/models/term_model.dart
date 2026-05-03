class TermsResponse {
  TermsResponse({required this.data});

  factory TermsResponse.fromJson(Map<String, dynamic> json) {
    return TermsResponse(
        data: TermsData.fromJson(json['data'] ?? json['status']));
  }
  final TermsData data;
}

class TermsData {
  TermsData({required this.privacyPolicy, required this.termAndCond});

  factory TermsData.fromJson(dynamic json) {
    CmsItem? privacyPolicy;
    CmsItem? termAndCond;

    if (json is List) {
      for (var item in json) {
        if (item is Map<String, dynamic>) {
          final slug = (item['slug'] ??
                  item['type'] ??
                  item['name'] ??
                  item['title'] ??
                  "")
              .toString()
              .toLowerCase();
          if (slug.contains('privacy')) {
            privacyPolicy = CmsItem.fromJson(item);
          } else if (slug.contains('term') ||
              slug.contains('legal') ||
              slug.contains('condition')) {
            termAndCond = CmsItem.fromJson(item);
          }
        }
      }
    } else if (json is Map<String, dynamic>) {
      final targetMap =
          (json['data'] is Map<String, dynamic>) ? json['data'] : json;

      if (targetMap['privacyPolicy'] != null) {
        privacyPolicy = CmsItem.fromJson(targetMap['privacyPolicy']);
      }
      if (targetMap['termAndCond'] != null) {
        termAndCond = CmsItem.fromJson(targetMap['termAndCond']);
      }
    }

    return TermsData(
      privacyPolicy: privacyPolicy ?? CmsItem(id: '', description: ''),
      termAndCond: termAndCond ?? CmsItem(id: '', description: ''),
    );
  }
  final CmsItem privacyPolicy;
  final CmsItem termAndCond;
}

class CmsItem {
  CmsItem({required this.id, required this.description});

  factory CmsItem.fromJson(Map<String, dynamic> json) {
    return CmsItem(
      id: (json['id'] ?? json['_id'] ?? "").toString(),
      description: (json['description'] ?? json['content'] ?? "").toString(),
    );
  }
  final String id;
  final String description;
}
