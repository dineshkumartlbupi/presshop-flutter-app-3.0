class IncidentViewRequest {
  IncidentViewRequest({
    required this.incidentId,
    required this.userId,
  });

  final String incidentId;
  final String userId;

  Map<String, dynamic> toJson() {
    return {
      'incidentId': incidentId,
      'userId': userId,
    };
  }
}

class IncidentViewResponse {
  IncidentViewResponse({
    this.incidentId,
    this.viewCount,
  });

  final String? incidentId;
  final int? viewCount;

  factory IncidentViewResponse.fromJson(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) {
      return IncidentViewResponse();
    }
    return IncidentViewResponse(
      incidentId: json['incidentId']?.toString(),
      viewCount: json['view_count'] as int?,
    );
  }
}
