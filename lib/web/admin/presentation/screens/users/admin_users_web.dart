import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/presentation/cubits/users/admin_users_cubit.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_stat_card.dart';
import 'package:ship_link/web/admin/presentation/screens/users/widgets/users_widgets.dart';

// شاشة عرض كل المستخدمين في جدول
class AdminUsersWeb extends StatelessWidget {
  const AdminUsersWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminUsersCubit, dynamic>(
      builder: (context, state) {
        if (state is AdminUsersInitial) {
          context.read<AdminUsersCubit>().loadUsers();
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminUsersLoading) {
          return const UsersTableShimmer();
        }
        if (state is AdminUsersError) {
          return UsersErrorView(state.message);
        }
        final users = (state is AdminUsersLoaded) ? state.users : <Map<String, dynamic>>[];

        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AdminSectionTitle('Users'),
              SizedBox(height: 16.h),
              UsersTable(users),
            ],
          ),
        );
      },
    );
  }
}
