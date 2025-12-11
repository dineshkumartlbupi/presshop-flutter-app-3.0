class CameraData {
  String path;
  String mimeType = "";
  String videoImagePath = "";
  String latitude = "";
  String location = "";
  String longitude = "";
  String country = "";
  String city = "";
  String state = "";
  String dateTime = "";
  bool fromGallary = false;

  CameraData(
      {required this.path,
      required this.mimeType,
      required this.videoImagePath,
      required this.latitude,
      required this.longitude,
      required this.location,
      required this.country,
      required this.city,
      required this.state,
      this.fromGallary = false,
      required this.dateTime});
}
