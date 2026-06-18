import 'package:get_it/get_it.dart';

import '../data/services/DriverHomeServeices/driver_home_imp.dart';
import '../data/services/cartServeices/cart_serveicesimpl.dart';
import '../data/services/homeServeice/home_serveices_impl.dart';

final getIt = GetIt.instance;
void setupServeiceLocator() {
  getIt.registerSingleton<HomeServeicesImpl>(
    HomeServeicesImpl(),
  );
  getIt.registerSingleton<CartServeicesImpl>(
    CartServeicesImpl(),
  );
  getIt.registerSingleton<DriverHomeServeicesImpl>(
    DriverHomeServeicesImpl(),
  );
}
