import 'package:dio/dio.dart';
void main() async {
  final dio = Dio();
  try {
    final response = await dio.get('https://funnellike-subangular-sulema.ngrok-free.dev/api/hopper/getGenralMgmtApp', queryParameters: {'type': 'price'});
    print('Response: ${response.data}');
  } catch(e) {
    if (e is DioException) {
      print('DioError: ${e.response?.data}');
    } else {
      print('Error: $e');
    }
  }
}
