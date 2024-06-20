import 'package:dio/dio.dart';

abstract class Failure {
  final String errMessage;
  Failure(this.errMessage);
}

class ServerFailure extends Failure {
  ServerFailure(super.errMesssage);
  factory ServerFailure.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure("Connection timeout with Apiserveices");
      case DioExceptionType.sendTimeout:
        return ServerFailure("Send timeout with Apiserveices");
      case DioExceptionType.receiveTimeout:
        return ServerFailure("Receive timeout with Apiserveices");
      case DioExceptionType.badCertificate:
        return ServerFailure("Connection badCertificate with Apiserveices");
      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
            dioError.response!.statusCode!, dioError.response!.data);
      case DioExceptionType.cancel:
        return ServerFailure("requist to ApiResponse was canceld");
      case DioExceptionType.connectionError:
        return ServerFailure(
            "something error happen in connection , try again later!");
      case DioExceptionType.unknown:
        if (dioError.message!.contains("SocketExeption")) {
          return ServerFailure("not enternet connection");
        }
        return ServerFailure("Unexpected error ,pls try again later!");
      default:
        return ServerFailure("${dioError.message}");
    }
  }
  factory ServerFailure.fromResponse(int statusCode, dynamic response) {
    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      return ServerFailure(response.toString());
    } else if (statusCode == 404) {
      return ServerFailure("Your request not found, try again later!");
    } else if (statusCode == 500) {
      return ServerFailure("Internal server error , try again later");
    } else {
      print(response);
      return ServerFailure(response);
    }
  }
}
