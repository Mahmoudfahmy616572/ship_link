import 'package:dio/dio.dart';

class ApiServeices {
  // String token = '';
  final _baseurl = "https://shiplink.spider-te8.com/api/";
// var header = {"Accept": "application/json", "Authorization": 'Bearer $token'};
  final Dio _dio;
  ApiServeices(this._dio);
  Future<Map<String, dynamic>> getHttp(
      {required String endpoint, required Map<String, String> headers}) async {
    var response = await _dio.get("$_baseurl$endpoint",
        options: Options(headers: headers));
    return response.data;
  }

  Future<Map<String, dynamic>> postHttp(
      {required String endpoint,
      required Map<String, String> headers,
      required int id,
      Object? data,
      Map<String, dynamic>? queryParameters}) async {
    var response = await _dio.post(
      "$_baseurl$endpoint",
      options: Options(headers: headers),
      queryParameters:queryParameters ,
      data: data,
    );
    print(response.data);
    return response.data;
  }

  // Future<Map<String, dynamic>> postHttpCart(
  //     {required String endpoint,
  //     required Map<String, String> headers,
  //     required int id}) async {
  //   var response = await _dio.post(
  //     "$_baseurl$endpoint",
  //     options: Options(headers: headers),
  //     data: {"user_id": '2', "cart_id": id.toString()},
  //   );

  //   print(response.data);
  //   return response.data;
  // }

  // Future<Map<String, dynamic>> postHttpUpdate(
  //     {required String endpoint,
  //     required Map<String, String> headers,
  //     required int id}) async {
  //   var response = await _dio.post(
  //     "$_baseurl$endpoint",
  //     options: Options(headers: headers),
  //     data: {"state_id": id.toString()},
  //   );

  //   print(response.data);
  //   return response.data;
  // }

  Future<Map<String, dynamic>> deleteHttp({
    required String endpoint,
    required Map<String, String> headers,
  }) async {
    var response = await _dio.delete(
      "$_baseurl$endpoint ",
      options: Options(headers: headers),
    );
    print(response.data);
    return response.data;
  }

//=========================Auth end points=========================
  // String register = 'auth/register';
  // String singin = 'auth/login';
  // String singout = 'auth/logout';

//=========================Products end points=========================

  // String getProducts = 'Products/get';
  // String addProducts = 'product/add';
  // String getfromCart = 'product/getFromCart';
  // String singleProductpath = 'Products/getSingle';
}
