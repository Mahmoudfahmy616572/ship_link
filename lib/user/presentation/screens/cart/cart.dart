import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/constants/services_locators.dart';
import 'package:ship_link/user/presentation/cubits/confirmCart/confirm_cart_cubit.dart';
import 'package:ship_link/user/presentation/cubits/getFromCart/get_from_cart_cubit.dart';
import 'package:ship_link/user/presentation/cubits/payment/payment_cubit.dart';
import 'package:ship_link/user/domain/repositories/cart_repository.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/user/presentation/screens/cart/components/body.dart';

class Cart extends StatelessWidget {
  const Cart({super.key});
  static String routName = '/Cart';

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GetFromCartCubit(
            getIt.get<CartRepository>(),
          ),
        ),
        BlocProvider(
          create: (_) => ConfirmCartCubit(
            getIt.get<CartRepository>(),
          ),
        ),
        BlocProvider(
          create: (_) => PaymentCubit(
            getIt.get<CartRepository>(),
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
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<GetFromCartCubit>().getProductFromCart());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          context.t.tr('my_cart'),
          style: appStyle(20, FontWeight.w700, AppColors.textPrimary),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<GetFromCartCubit>().getProductFromCart(),
        child: Body(scrollController: _scrollController),
      ),
    );
  }
}
