import 'package:get_it/get_it.dart';

import 'package:ship_link/web/domain/repositories/home_repository.dart';
import 'package:ship_link/web/domain/repositories/cart_repository.dart';
import 'package:ship_link/web/domain/repositories/favourite_repository.dart';
import 'package:ship_link/web/domain/repositories/review_repository.dart';
import 'package:ship_link/web/domain/repositories/payment_methods_repository.dart';
import 'package:ship_link/web/data/repositories/home_repository_impl.dart';
import 'package:ship_link/web/data/repositories/cart_repository_impl.dart';
import 'package:ship_link/web/data/repositories/favourite_repository_impl.dart';
import 'package:ship_link/web/data/repositories/review_repository_impl.dart';
import 'package:ship_link/web/data/repositories/payment_methods_repository_impl.dart';

import 'package:ship_link/web/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/web/presentation/cubits/addToCart/add_to_cart_cubit.dart';
import 'package:ship_link/web/presentation/cubits/confirmCart/confirm_cart_cubit.dart';
import 'package:ship_link/web/presentation/cubits/favourite/favourite_cubit.dart';
import 'package:ship_link/web/presentation/cubits/getAllProducts/get_all_prouducts_cubit.dart';
import 'package:ship_link/web/presentation/cubits/getFromCart/get_from_cart_cubit.dart';
import 'package:ship_link/web/presentation/cubits/getTopSeller/get_top_seller_cubit.dart';
import 'package:ship_link/web/presentation/cubits/orderHistory/order_history_cubit.dart';
import 'package:ship_link/web/presentation/cubits/payment/payment_cubit.dart';
import 'package:ship_link/web/presentation/cubits/chats/chat_list_cubit.dart';
import 'package:ship_link/web/presentation/cubits/chats/support_chat_cubit.dart';
import 'package:ship_link/web/presentation/cubits/homeFilter/home_filter_cubit.dart';
import 'package:ship_link/web/presentation/cubits/notification/notification_cubit.dart';
import 'package:ship_link/web/presentation/cubits/search/search_cubit.dart';
import 'package:ship_link/web/presentation/cubits/address/address_cubit.dart';
import 'package:ship_link/web/presentation/cubits/profileEdit/profile_edit_cubit.dart';
import 'package:ship_link/web/presentation/cubits/checkout/checkout_cubit.dart';

import 'package:ship_link/web/admin/domain/repositories/admin_repository.dart';
import 'package:ship_link/web/admin/data/repositories/admin_repository_impl.dart';
import 'package:ship_link/web/admin/presentation/cubits/admin_auth/admin_auth_cubit.dart';
import 'package:ship_link/web/admin/presentation/cubits/dashboard/admin_dashboard_cubit.dart';
import 'package:ship_link/web/admin/presentation/cubits/users/admin_users_cubit.dart';
import 'package:ship_link/web/admin/presentation/cubits/drivers/admin_drivers_cubit.dart';
import 'package:ship_link/web/admin/presentation/cubits/orders/admin_orders_cubit.dart';
import 'package:ship_link/web/admin/presentation/cubits/products/admin_products_cubit.dart';

final getIt = GetIt.instance;
void setupWebServiceLocator() {
  getIt.registerSingleton<HomeRepository>(HomeRepositoryImpl());
  getIt.registerSingleton<CartRepository>(CartRepositoryImpl());
  getIt.registerSingleton<FavouriteRepository>(FavouriteRepositoryImpl());
  getIt.registerSingleton<ReviewRepository>(ReviewRepositoryImpl());
  getIt.registerSingleton<PaymentMethodsRepository>(PaymentMethodsRepositoryImpl());

  getIt.registerSingleton<AuthCubit>(AuthCubit());
  getIt.registerFactory<AddToCartCubit>(() => AddToCartCubit(getIt<CartRepository>()));
  getIt.registerFactory<ConfirmCartCubit>(() => ConfirmCartCubit(getIt<CartRepository>()));
  getIt.registerFactory<FavouriteCubit>(() => FavouriteCubit(getIt<FavouriteRepository>()));
  getIt.registerFactory<GetAllProuductsCubit>(() => GetAllProuductsCubit(getIt<HomeRepository>()));
  getIt.registerFactory<GetFromCartCubit>(() => GetFromCartCubit(getIt<CartRepository>()));
  getIt.registerFactory<GetTopSellerCubit>(() => GetTopSellerCubit(getIt<HomeRepository>()));
  getIt.registerFactory<OrderHistoryCubit>(() => OrderHistoryCubit(getIt<CartRepository>()));
  getIt.registerFactory<PaymentCubit>(() => PaymentCubit(getIt<CartRepository>()));
  getIt.registerSingleton<ChatListCubit>(ChatListCubit());
  getIt.registerSingleton<SupportChatCubit>(SupportChatCubit());
  getIt.registerSingleton<HomeFilterCubit>(HomeFilterCubit());
  getIt.registerSingleton<NotificationCubit>(NotificationCubit());
  getIt.registerSingleton<SearchCubit>(SearchCubit());
  getIt.registerSingleton<AddressCubit>(AddressCubit());
  getIt.registerSingleton<ProfileEditCubit>(ProfileEditCubit());
  getIt.registerSingleton<CheckoutCubit>(CheckoutCubit());

  getIt.registerSingleton<AdminRepository>(AdminRepositoryImpl());
  getIt.registerSingleton<AdminAuthCubit>(AdminAuthCubit(getIt<AdminRepository>()));
  getIt.registerFactory<AdminDashboardCubit>(() => AdminDashboardCubit(getIt<AdminRepository>()));
  getIt.registerFactory<AdminUsersCubit>(() => AdminUsersCubit(getIt<AdminRepository>()));
  getIt.registerFactory<AdminDriversCubit>(() => AdminDriversCubit(getIt<AdminRepository>()));
  getIt.registerFactory<AdminOrdersCubit>(() => AdminOrdersCubit(getIt<AdminRepository>()));
  getIt.registerFactory<AdminProductsCubit>(() => AdminProductsCubit(getIt<AdminRepository>()));
}
