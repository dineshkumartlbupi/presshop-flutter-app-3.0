class ServerException implements Exception {
  ServerException(this.message);
  final String message;
}

class CacheException implements Exception {
  CacheException(this.message);
  final String message;
}

class LocationException implements Exception {
  LocationException(this.message);
  final String message;
}

class ProcessingException implements Exception {
  ProcessingException(this.message);
  final String message;
}
