import 'package:get_it/get_it.dart';

import 'package:ship_link/user/domain/repositories/home_repository.dart';
import 'package:ship_link/user/domain/repositories/cart_repository.dart';
import 'package:ship_link/user/domain/repositories/favourite_repository.dart';
import 'package:ship_link/user/data/repositories/home_repository_impl.dart';
import 'package:ship_link/user/data/repositories/cart_repository_impl.dart';
import 'package:ship_link/user/data/repositories/favourite_repository_impl.dart';
import 'package:ship_link/driver/domain/repositories/driver_home_repository.dart';
import 'package:ship_link/driver/data/repositories/driver_home_repository_impl.dart';

final getIt = GetIt.instance;
void setupServeiceLocator() {
  getIt.registerLazySingleton<DriverHomeRepository>(
    () => DriverHomeRepositoryImpl(),
  );
  getIt.registerSingleton<HomeRepository>(
    HomeRepositoryImpl(),
  );
  getIt.registerSingleton<CartRepository>(
    CartRepositoryImpl(),
  );
  getIt.registerSingleton<FavouriteRepository>(
    FavouriteRepositoryImpl(),
  );
}
