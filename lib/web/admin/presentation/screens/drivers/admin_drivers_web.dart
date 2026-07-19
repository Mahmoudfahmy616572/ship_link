import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/presentation/cubits/drivers/admin_drivers_cubit.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_stat_card.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_toast.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_empty_state.dart';
import 'package:ship_link/web/admin/presentation/screens/drivers/widgets/drivers_widgets.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_theme_mode.dart';

// شاشة إدارة السائقين (عرض + تفعيل السائق اللي معاه عربية)
class AdminDriversWeb extends StatefulWidget {
  final void Function(Map<String, dynamic> driver)? onOpen;
  const AdminDriversWeb({super.key, this.onOpen});

  @override
  State<AdminDriversWeb> createState() => _AdminDriversWebState();
}

class _AdminDriversWebState extends State<AdminDriversWeb> {
  String _search = '';
  Timer? _searchTimer;

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    _search = v;
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 300), () => context.read<AdminDriversCubit>().loadDrivers(search: v.isEmpty ? null : v));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return BlocConsumer<AdminDriversCubit, dynamic>(
      listener: (context, state) {
        if (state is AdminDriverUpdateSuccess) {
          final d = (context.read<AdminDriversCubit>().state is AdminDriversLoaded)
              ? (context.read<AdminDriversCubit>().state as AdminDriversLoaded)
                  .drivers
                  .firstWhere((x) => x['id'] == state.id, orElse: () => <String, dynamic>{})
              : <String, dynamic>{};
          AdminToast.success(context, '${context.t.tr('driver_activated')} : ${d['name']?.toString() ?? ''}');
          // نعيد تحميل القائمة عشان تتحدث
          context.read<AdminDriversCubit>().loadDrivers(search: _search.isEmpty ? null : _search);
        } else if (state is AdminDriversError && state.message.isNotEmpty) {
          AdminToast.error(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is AdminDriversInitial) {
          context.read<AdminDriversCubit>().loadDrivers();
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminDriversLoading) {
          return const DriversTableShimmer();
        }
        if (state is AdminDriversError) {
          return DriversErrorView(state.message, () => context.read<AdminDriversCubit>().loadDrivers());
        }
        final drivers = (state is AdminDriversLoaded) ? state.drivers : <Map<String, dynamic>>[];
        final hasMore = (state is AdminDriversLoaded) ? state.hasMore : false;

        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminSectionTitle('Drivers', isDark: AdminThemeMode.isDark.value),
              SizedBox(height: 16.h),
              TextField(
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: t.tr('search_drivers'),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
              ),
              SizedBox(height: 16.h),
              if (drivers.isEmpty)
                AdminEmptyState(icon: Icons.local_shipping_outlined, message: t.tr('no_drivers'), onRetry: () => context.read<AdminDriversCubit>().loadDrivers(search: _search.isEmpty ? null : _search), isDark: AdminThemeMode.isDark.value)
              else ...[
                DriversTable(
                  drivers,
                  isCompact: MediaQuery.of(context).size.width <= 900,
                  onOpen: widget.onOpen,
                onActivate: (d) async {
                  final confirmed = await AdminConfirmDialog.show(
                    context,
                    title: context.t.tr('activate_driver_title'),
                    message: context.t.tr('activate_driver_confirm'),
                  );
                  if (confirmed) {
                    // نفعل السائق عن طريق تحديث حالة المركبة
                    context.read<AdminDriversCubit>().updateDriver(
                      id: d['id'].toString(),
                      fields: {'state': d['state']?.toString() ?? 'active'},
                    );
                  }
                },
              ),
                if (hasMore)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: OutlinedButton.icon(
                        onPressed: () => context.read<AdminDriversCubit>().loadMoreDrivers(search: _search.isEmpty ? null : _search),
                        icon: const Icon(Icons.expand_more, size: 18),
                        label: Text(t.tr('load_more')),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}
