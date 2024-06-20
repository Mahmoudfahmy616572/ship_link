import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../data/services/cartServeices/cart_serveicesimpl.dart';
import '../data/services/homeServeice/home_serveices_impl.dart';
import 'api_serveices.dart';

final getIt = GetIt.instance;
void setupServeiceLocator() {
  getIt.registerSingleton<ApiServeices>(
    ApiServeices(
      Dio(),
    ),
  );
  getIt.registerSingleton<HomeServeicesImpl>(
    HomeServeicesImpl(
      getIt.get<ApiServeices>(),
    ),
  );
  getIt.registerSingleton<CartServeicesImpl>(
      CartServeicesImpl(getIt.get<ApiServeices>()));
}
