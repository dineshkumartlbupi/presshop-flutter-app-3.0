class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

class LocationException implements Exception {
  final String message;
  LocationException(this.message);
}
