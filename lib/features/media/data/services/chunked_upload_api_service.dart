import 'package:dio/dio.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/core/utils/shared_preferences.dart';

class ChunkedUploadApiService {
  final Dio _dio = Dio();

  String get _baseUrl => ApiConstantsNew.config.baseUrl;

  Future<String> _getToken() async {
    final prefs = await getSharedPreferences();
    return prefs.getString(SharedPreferencesKeys.tokenKey) ?? '';
  }

  Future<Map<String, dynamic>> initiateUpload({
    required String filename,
    required String contentType,
    required int partCount,
  }) async {
    final token = await _getToken();
    final url = '$_baseUrl${ApiConstantsNew.content.initiateUpload}';
    
    final response = await _dio.post(
      url,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
      data: {
        'filename': filename,
        'contentType': contentType,
        'partCount': partCount,
      },
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception('Failed to initiate upload: ${response.statusCode}');
    }
  }

  Future<String> uploadChunk({
    required String presignedUrl,
    required List<int> chunkData,
  }) async {
    final response = await _dio.put(
      presignedUrl,
      options: Options(
        headers: {
          'Content-Length': chunkData.length.toString(),
        },
        responseType: ResponseType.plain,
      ),
      data: Stream.fromIterable([chunkData]),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final eTag = response.headers.value('etag') ?? response.headers.value('ETag');
      if (eTag == null) {
        throw Exception('No ETag in response headers');
      }
      return eTag;
    } else {
      throw Exception('Failed to upload chunk: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> completeUpload({
    required String key,
    required String uploadId,
    required String mediaType,
    required String originalFileName,
    required String userId,
    required List<Map<String, dynamic>> parts,
    String? contentId,
  }) async {
    final token = await _getToken();
    final url = '$_baseUrl${ApiConstantsNew.content.completeUpload}';
    
    final data = {
      'key': key,
      'uploadId': uploadId,
      'mediaType': mediaType,
      'originalFileName': originalFileName,
      'userId': userId,
      'contentId': contentId,
      'parts': parts,
    };
    
    data.removeWhere((key, value) => value == null);

    final response = await _dio.post(
      url,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
      data: data,
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception('Failed to complete upload: ${response.statusCode}');
    }
  }

  Future<void> abortUpload({
    required String key,
    required String uploadId,
  }) async {
    final token = await _getToken();
    final url = '$_baseUrl${ApiConstantsNew.content.abortUpload}';
    
    await _dio.post(
      url,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
      data: {
        'key': key,
        'uploadId': uploadId,
      },
    );
  }

  Future<String> getMediaStatus(String videoId) async {
    final token = await _getToken();
    final url = '$_baseUrl${ApiConstantsNew.content.mediaStatus}$videoId';
    
    final response = await _dio.get(
      url,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    
    if (response.statusCode == 200) {
      return response.data['status'] ?? 'unknown';
    } else {
      throw Exception('Failed to get media status: ${response.statusCode}');
    }
  }
}
