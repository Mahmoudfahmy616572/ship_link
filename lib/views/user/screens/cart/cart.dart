import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/constant/services_locators.dart';
import 'package:ship_link/cubits/confirmCart/confirm_cart_cubit.dart';
import 'package:ship_link/cubits/getFromCart/get_from_cart_cubit.dart';
import 'package:ship_link/cubits/payment/payment_cubit.dart';
import 'package:ship_link/data/services/cartServeices/cart_serveicesimpl.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/views/user/screens/cart/components/body.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});
  static String routName = '/Cart';

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GetFromCartCubit(
            getIt.get<CartServeicesImpl>(),
          ),
        ),
        BlocProvider(
          create: (_) => ConfirmCartCubit(
            getIt.get<CartServeicesImpl>(),
          ),
        ),
        BlocProvider(
          create: (_) => PaymentCubit(
            getIt.get<CartServeicesImpl>(),
          ),
        ),
      ],
      child: const _CartScreen(),
    );
  }
}

class _CartScreen extends StatefulWidget {
  const _CartScreen();

  @override
  State<_CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<_CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<GetFromCartCubit>().getProductFromCart());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: Text(
          context.t.tr('my_cart'),
          style: appStyle(20, FontWeight.w700, AppColors.textPrimary),
        ),
      ),
      body: const Body(),
    );
  }
}
