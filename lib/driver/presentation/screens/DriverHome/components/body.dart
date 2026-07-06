import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/constants/Errors/custom_error_widget.dart';
import 'package:ship_link/driver/presentation/cubits/acceptOrder/accept_order_cubit.dart';
import 'package:ship_link/driver/presentation/cubits/getAcceptedOrders/get_accepted_order_cubit.dart';
import 'package:ship_link/driver/presentation/cubits/get_orders/get_orders_cubit.dart';
import 'package:ship_link/driver/presentation/cubits/get_user_driver_data/get_userdriver_data_cubit.dart';
import 'package:ship_link/driver/data/repositories/driver_earnings_repository_impl.dart';
import 'package:ship_link/driver/presentation/screens/OrdersMap/orders_map_screen.dart';
import 'package:ship_link/driver/presentation/screens/chat/driver_chat_list_screen.dart';
import 'package:ship_link/core/services/driver/driver_location_service.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/notification_bell.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> with AutomaticKeepAliveClientMixin {
  final _isOnline = ValueNotifier<bool>(false);
  final _locationService = DriverLocationService();
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetOrdersCubit>().getOrder();
    });
  }

  @override
  void dispose() {
    _isOnline.dispose();
    _scrollController.dispose();
    _locationService.stop();
    super.dispose();
  }

  @override
  void updateKeepAlive() {
    super.updateKeepAlive();
  }

  void _refreshAll() {
    if (!mounted) return;
    context.read<GetOrdersCubit>().getOrder();
    context.read<GetAcceptedOrderCubit>().getAcceptedOrder();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<GetOrdersCubit>().getOrder();
            context.read<GetAcceptedOrderCubit>().getAcceptedOrder();
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildGreetingBar(),
              _buildStatsRow(),
              _buildActiveDelivery(),
              _buildAvailableOrdersSection(),
              SliverPadding(padding: EdgeInsets.only(bottom: 80.h)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingBar() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24.r),
            bottomRight: Radius.circular(24.r),
          ),
          boxShadow: [
            BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: BlocBuilder<GetUserdriverDataCubit, GetUserdriverDataState>(
                    builder: (context, state) {
                      final name = state is GetUserdriverDataSuccess
                          ? state.getuserDriverData.data?.name ?? 'Driver'
                          : 'Driver';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${context.t.tr('hello')}, $name',
                              style: appStyle(20, FontWeight.w600, const Color(0xFF111827))),
                          SizedBox(height: 2.h),
                          ValueListenableBuilder<bool>(
                            valueListenable: _isOnline,
                            builder: (context, isOnline, _) {
                              return Text(isOnline ? context.t.tr('ready_for_deliveries') : context.t.tr('youre_offline'),
                                  style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280)));
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const NotificationBell(iconColor: Color(0xFF111827)),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF111827)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverChatListScreen())),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _isOnline,
                  builder: (context, isOnline, _) {
                    return GestureDetector(
                      onTap: () async {
                        final newValue = !isOnline;
                        if (newValue) {
                          await _locationService.start();
                        } else {
                          await _locationService.stop();
                        }
                        if (mounted) _isOnline.value = newValue;
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isOnline ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8.w, height: 8.h,
                              decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(isOnline ? context.t.tr('online') : context.t.tr('offline'),
                                style: appStyle(13, FontWeight.w600, Colors.white)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 8.h),
        child: BlocBuilder<GetAcceptedOrderCubit, GetAcceptedOrderState>(
          builder: (context, state) {
            final count = state is GetAcceptedOrderSuccess
                ? state.getAcceptedOrder.data?.order?.length ?? 0
                : 0;
            return Row(
              children: [
                _buildStatCard(Icons.delivery_dining, '$count', context.t.tr('active'), AppColors.primary),
                SizedBox(width: 12.w),
                _buildRatingCard(),
                SizedBox(width: 12.w),
                _buildEarningsCard(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRatingCard() {
    final driverId = Supabase.instance.client.auth.currentUser?.id;
    if (driverId == null) {
      return _buildStatCard(Icons.star, '0.0 (0)', context.t.tr('rating'), AppColors.starFilled);
    }
    return FutureBuilder<Map<String, dynamic>>(
      future: _getDriverRating(driverId),
      builder: (context, snapshot) {
        final avg = snapshot.data?['avg'] as double? ?? 0;
        final cnt = snapshot.data?['count'] as int? ?? 0;
        return _buildStatCard(Icons.star, '${avg.toStringAsFixed(1)} ($cnt)', context.t.tr('rating'), AppColors.starFilled);
      },
    );
  }

  Future<Map<String, dynamic>> _getDriverRating(String driverId) async {
    try {
      final data = await Supabase.instance.client
          .from('driver_ratings')
          .select('rating')
          .eq('driver_id', driverId);
      if (data.isEmpty) return {'avg': 0.0, 'count': 0};
      double sum = 0;
      for (final row in data) {
        sum += (row['rating'] as num).toDouble();
      }
      return {'avg': sum / data.length, 'count': data.length};
    } catch (_) {
      return {'avg': 0.0, 'count': 0};
    }
  }

  Widget _buildEarningsCard() {
    final driverId = Supabase.instance.client.auth.currentUser?.id;
    if (driverId == null) {
      return _buildStatCard(Icons.attach_money, '\$0', context.t.tr('today'), AppColors.success);
    }
    return FutureBuilder<double>(
      future: DriverEarningsRepositoryImpl().getTodayEarnings(driverId).then((r) => r.fold((_) => 0.0, (v) => v)),
      builder: (context, snapshot) {
        final value = snapshot.data ?? 0;
        return _buildStatCard(Icons.attach_money, '\$${value.toStringAsFixed(0)}', context.t.tr('today'), AppColors.success);
      },
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: const [
            BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            SizedBox(height: 4.h),
            Text(value, style: appStyle(18, FontWeight.w700, const Color(0xFF111827))),
            Text(label, style: appStyle(12, FontWeight.w400, const Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveDelivery() {
    return BlocBuilder<GetAcceptedOrderCubit, GetAcceptedOrderState>(
      builder: (context, state) {
        if (state is GetAcceptedOrderSuccess &&
            (state.getAcceptedOrder.data?.order?.length ?? 0) > 0) {
                  final order = state.getAcceptedOrder.data!.order!.first;
          final status = order.status?.toString().toLowerCase() ?? '';
          final steps = [context.t.tr('accepted'), context.t.tr('picked_up'), context.t.tr('in_transit'), context.t.tr('delivered')];
          final statusMap = {'accepted': 0, 'picked_up': 1, 'shipped': 2, 'delivered': 3};
          final currentStep = statusMap[status] ?? 0;
          return SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 12,
                      offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(context.t.tr('active_delivery'),
                            style: appStyle(12, FontWeight.w600, const Color(0xFFD97706))),
                      ),
                      const Spacer(),
                      Text('#${order.id ?? ''}',
                          style: appStyle(14, FontWeight.w600, const Color(0xFF111827))),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: List.generate(steps.length, (i) => _step(steps[i], i <= currentStep)),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 18, color: Color(0xFF6B7280)),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(order.customerName ?? order.user?.firstName ?? context.t.tr('customer'),
                            style: appStyle(15, FontWeight.w500, const Color(0xFF111827))),
                      ),
                      SizedBox(width: 8.w),
                      Text('${context.t.tr('egp')} ${order.totalPrice ?? '0'}',
                          style: appStyle(18, FontWeight.w700, const Color(0xFF10B981))),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF6B7280)),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: GestureDetector(
                          onTap: () async {
                            final phone = (order.phoneNumber?.isNotEmpty == true ? order.phoneNumber : order.user?.phoneNumber) ?? '';
                            if (phone.isNotEmpty) {
                              await launchUrl(Uri.parse('tel:$phone'));
                            }
                          },
                          child: Text(order.phoneNumber?.isNotEmpty == true ? order.phoneNumber! : (order.user?.phoneNumber ?? ''),
                              style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280))),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildStatusActions(context, order, status),
                ],
              ),
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildStatusActions(BuildContext context, dynamic order, String status) {
    if (status == 'accepted') {
      return Row(
        children: [
          Expanded(
            child: _ActionBtn(
              label: context.t.tr('mark_picked_up'),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              backgroundColor: AppColors.primary,
              onAction: () async {
                await context.read<AcceptOrderCubit>().markPickedUp(orderId: order.id);
                _refreshAll();
              },
            ),
          ),
          SizedBox(width: 12.w),
          SizedBox(
            height: 44.h,
            child: _ActionBtn(
              label: context.t.tr('cancel'),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              isOutlined: true,
              fgColor: const Color(0xFFDC2626),
              side: const BorderSide(color: Color(0xFFDC2626)),
              onAction: () async {
                await context.read<AcceptOrderCubit>().cancelOrder(orderId: order.id);
                _refreshAll();
              },
            ),
          ),
        ],
      );
    }
    if (status == 'picked_up') {
      return Row(
        children: [
          Expanded(
            child: _ActionBtn(
              label: context.t.tr('mark_shipped'),
              icon: const Icon(Icons.local_shipping, size: 18),
              backgroundColor: const Color(0xFFD97706),
              onAction: () async {
                await context.read<AcceptOrderCubit>().markShipped(orderId: order.id);
                _refreshAll();
              },
            ),
          ),
          SizedBox(width: 12.w),
          SizedBox(
            height: 44.h,
            child: _ActionBtn(
              label: context.t.tr('cancel'),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              isOutlined: true,
              fgColor: const Color(0xFFDC2626),
              side: const BorderSide(color: Color(0xFFDC2626)),
              onAction: () async {
                await context.read<AcceptOrderCubit>().cancelOrder(orderId: order.id);
                _refreshAll();
              },
            ),
          ),
        ],
      );
    }
    if (status == 'shipped') {
      return Row(
        children: [
          Expanded(
            child: _ActionBtn(
              label: context.t.tr('mark_delivered'),
              icon: const Icon(Icons.check_circle, size: 18),
              backgroundColor: const Color(0xFF059669),
              onAction: () async {
                await context.read<AcceptOrderCubit>().markDelivered(orderId: order.id);
                _refreshAll();
              },
            ),
          ),
          SizedBox(width: 12.w),
          SizedBox(
            height: 44.h,
            child: _ActionBtn(
              label: context.t.tr('cancel'),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              isOutlined: true,
              fgColor: const Color(0xFFDC2626),
              side: const BorderSide(color: Color(0xFFDC2626)),
              onAction: () async {
                await context.read<AcceptOrderCubit>().cancelOrder(orderId: order.id);
                _refreshAll();
              },
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _step(String label, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 10.w, height: 10.h,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : const Color(0xFFD1D5DB),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: 4.h),
          Text(label,
              style: appStyle(10, FontWeight.w500,
                  isActive ? AppColors.primary : const Color(0xFF9CA3AF)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildAvailableOrdersSection() {
    return BlocBuilder<GetOrdersCubit, GetOrdersState>(
      builder: (context, state) {
        final orders = state is GetOrdersSuccess
            ? state.getOrder.data?.order
                ?.where((o) => o.status?.toLowerCase() == "pending")
                .toList()
            : <dynamic>[];

        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
                child: Row(
                  children: [
                    Text(context.t.tr('available_orders'),
                        style: appStyle(18, FontWeight.w700, const Color(0xFF111827))),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, OrdersMapScreen.routName),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.map_outlined, size: 16, color: Color(0xFF6B7280)),
                          SizedBox(width: 4.w),
                          Text(context.t.tr('map'),
                              style: appStyle(14, FontWeight.w500, const Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    if (orders != null)
                      Text('${orders.length}',
                          style: appStyle(14, FontWeight.w400, const Color(0xFF9CA3AF))),
                  ],
                ),
              ),
            ),
            if (state is GetOrdersLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state is GetOrdersFailure)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: CustomErrorWidget(errMessage: state.errMessage),
                ),
              )
            else if (orders == null || orders.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.w),
                    child: Column(
                      children: [
                        const Icon(Icons.inbox_outlined, size: 48, color: Color(0xFFD1D5DB)),
                        SizedBox(height: 12.h),
                        Text(context.t.tr('no_orders_available'),
                            style: appStyle(16, FontWeight.w500, const Color(0xFF9CA3AF))),
                        SizedBox(height: 4.h),
                        Text(context.t.tr('check_back_later'),
                            style: appStyle(14, FontWeight.w400, const Color(0xFFD1D5DB))),
                        SizedBox(height: 16.h),
                        Text(
                          context.t.tr('switch_to_orders_tab'),
                          style: appStyle(13, FontWeight.w400, const Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _orderCard(context, orders[index]),
                  childCount: orders.length,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _orderCard(BuildContext context, dynamic order) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w, height: 44.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(Icons.store, color: Color(0xFF6B7280), size: 24),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${context.t.tr('order_no')}${order.id ?? ''}',
                        style: appStyle(15, FontWeight.w600, const Color(0xFF111827))),
                    SizedBox(height: 2.h),
                    Text(order.customerName ?? order.user?.firstName ?? context.t.tr('customer'),
                        style: appStyle(13, FontWeight.w400, const Color(0xFF6B7280))),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(order.status ?? context.t.tr('pending'),
                    style: appStyle(12, FontWeight.w600, const Color(0xFFD97706))),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1),
          SizedBox(height: 12.h),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Color(0xFF6B7280)),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(order.user?.firstName ?? context.t.tr('customer'),
                    style: appStyle(13, FontWeight.w500, const Color(0xFF111827))),
              ),
              SizedBox(width: 8.w),
              Text('${context.t.tr('egp')} ${order.totalPrice ?? '0'}',
                  style: appStyle(18, FontWeight.w700, const Color(0xFF10B981))),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF6B7280)),
              SizedBox(width: 6.w),
              Flexible(
                child: GestureDetector(
                  onTap: () async {
                    final phone = (order.phoneNumber?.isNotEmpty == true ? order.phoneNumber : order.user?.phoneNumber) ?? '';
                    if (phone.isNotEmpty) {
                      await launchUrl(Uri.parse('tel:$phone'));
                    }
                  },
                  child: Text(order.phoneNumber?.isNotEmpty == true ? order.phoneNumber! : (order.user?.phoneNumber ?? ''),
                      style: appStyle(13, FontWeight.w400, const Color(0xFF6B7280))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatefulWidget {
  final String label;
  final Widget icon;
  final Color? backgroundColor;
  final Color? fgColor;
  final bool isOutlined;
  final BorderSide? side;
  final Future<void> Function() onAction;

  const _ActionBtn({
    required this.label,
    required this.icon,
    this.backgroundColor,
    this.fgColor,
    this.isOutlined = false,
    this.side,
    required this.onAction,
  });

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  final _loading = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _loading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _loading,
      builder: (context, loading, _) {
        return SizedBox(
          height: 44.h,
          child: widget.isOutlined
              ? OutlinedButton.icon(
                  onPressed: loading ? null : () async {
                    _loading.value = true;
                    await widget.onAction();
                    if (mounted) _loading.value = false;
                  },
                  icon: loading
                      ? SizedBox(width: 18.w, height: 18.h, child: CircularProgressIndicator(strokeWidth: 2))
                      : widget.icon,
                  label: Text(widget.label, style: appStyle(14, FontWeight.w600, widget.fgColor ?? const Color(0xFFDC2626))),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: widget.fgColor,
                    side: widget.side,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: loading ? null : () async {
                    _loading.value = true;
                    await widget.onAction();
                    if (mounted) _loading.value = false;
                  },
                  icon: loading
                      ? SizedBox(width: 18.w, height: 18.h, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : widget.icon,
                  label: Text(widget.label, style: appStyle(14, FontWeight.w600, Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.backgroundColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
        );
      },
    );
  }
}
