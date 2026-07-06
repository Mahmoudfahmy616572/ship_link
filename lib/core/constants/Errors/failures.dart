import 'package:dio/dio.dart';

abstract class Failure {
  final String errMessage;
  Failure(this.errMessage);
}

class ServerFailure extends Failure {
  ServerFailure(super.errMessage);
  factory ServerFailure.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure("Connection timeout with API");
      case DioExceptionType.sendTimeout:
        return ServerFailure("Send timeout with API");
      case DioExceptionType.receiveTimeout:
        return ServerFailure("Receive timeout with API");
      case DioExceptionType.badCertificate:
        return ServerFailure("Connection badCertificate with API");
      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
            dioError.response!.statusCode!, dioError.response!.data);
      case DioExceptionType.cancel:
        return ServerFailure("Request to API was cancelled");
      case DioExceptionType.connectionError:
        return ServerFailure(
            "Connection error, try again later!");
      case DioExceptionType.unknown:
        if (dioError.message!.contains("SocketExeption")) {
          return ServerFailure("No internet connection");
        }
        return ServerFailure("Unexpected error, try again later!");
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
      return ServerFailure("Unexpected error occurred");
    }
  }
}
