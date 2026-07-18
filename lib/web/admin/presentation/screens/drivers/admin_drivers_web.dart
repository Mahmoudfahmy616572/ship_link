import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/presentation/cubits/drivers/admin_drivers_cubit.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_stat_card.dart';
import 'package:ship_link/web/admin/presentation/screens/drivers/widgets/drivers_widgets.dart';

// شاشة إدارة السائقين (عرض + تفعيل السائق اللي معاه عربية)
class AdminDriversWeb extends StatefulWidget {
  final void Function(Map<String, dynamic> driver)? onOpen;
  const AdminDriversWeb({super.key, this.onOpen});

  @override
  State<AdminDriversWeb> createState() => _AdminDriversWebState();
}

class _AdminDriversWebState extends State<AdminDriversWeb> {
  String _search = '';

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
          showDriverUpdateSnackbar(context, d['name']?.toString() ?? '');
          // نعيد تحميل القائمة عشان تتحدث
          context.read<AdminDriversCubit>().loadDrivers(search: _search.isEmpty ? null : _search);
        } else if (state is AdminDriversError && state.message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
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

        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AdminSectionTitle('Drivers'),
              SizedBox(height: 16.h),
              TextField(
                onChanged: (v) {
                  _search = v;
                  context.read<AdminDriversCubit>().loadDrivers(search: v.isEmpty ? null : v);
                },
                decoration: InputDecoration(
                  hintText: t.tr('search_drivers'),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
              ),
              SizedBox(height: 16.h),
              DriversTable(
                drivers,
                onOpen: widget.onOpen,
                onActivate: (d) {
                  // نفعل السائق عن طريق تحديث حالة المركبة
                  context.read<AdminDriversCubit>().updateDriver(
                    id: d['id'].toString(),
                    fields: {'state': d['state']?.toString() ?? 'active'},
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
