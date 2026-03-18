class SocketEvents {
  // Authentication & Connection Rooms
  static const String joinWebsite = "joinWebsite";
  static const String joinAdmin = "joinAdmin";
  static const String joinHopper = "joinHopper";
  static const String joinUser = "joinUser";

  // Incident Events
  static const String incidentCreate = "incident:create";
  static const String incidentNew = "incident:new";
  static const String incidentUpdated = "incident:updated";
  static const String incidentCreated = "incident:created";

  // Room Events
  static const String joinNewsAll = "join:news:all";
  static const String joinContent = "join:content";

  // Comment & Interaction Emit Events
  static const String addAggregatedComment = "add:aggregated:comment";
  static const String addAggregatedCommentLike = "add:aggregated:comment:like";
  static const String addAggregatedNewsLike = "add:aggregated:news:like";
  static const String addAggregatedNewsView = "add:aggregated:news:view";
  static const String addAggregatedNewsShare = "add:aggregated:news:share";

  // Comment & Interaction Listen Events
  static const String aggregatedCommentLike = "aggregated:comment:like";
  static const String aggregatedCommentNew = "aggregated:comment:new";
  static const String aggregatedNewsLike = "aggregated:news:like";
  static const String aggregatedNewsShare = "aggregated:news:share";

  // Chat Events+6
  static const String chatMessage = "chat message";
  static const String mediaMessage = "media message";
  static const String voiceMessage = "voice message";
  static const String typing = "typing";
  static const String stopTyping = "stop typing";
  static const String roomJoin = "room join";
  static const String leaveRoom = "leave room";
  static const String adminStatus = "adminStatus";
  static const String readMessage = "read message";
}
