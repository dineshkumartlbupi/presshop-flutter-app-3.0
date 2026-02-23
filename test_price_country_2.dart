import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  try {
    final responseUS = await dio.get('https://funnellike-subangular-sulema.ngrok-free.dev/api/hopper/get/priceValue', queryParameters: {'country': 'US'});
    print('US: ${responseUS.data}');
    
    final responseIndia = await dio.get('https://funnellike-subangular-sulema.ngrok-free.dev/api/hopper/get/priceValue', queryParameters: {'country': 'India'});
    print('India: ${responseIndia.data}');
  } catch(e) {
    if (e is DioException) {
      print('DioError: ${e.response?.data}');
    } else {
      print('Error: $e');
    }
  }
}
