import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/presentation/cubits/users/admin_users_cubit.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_stat_card.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_empty_state.dart';
import 'package:ship_link/web/admin/presentation/screens/users/widgets/users_widgets.dart';

// شاشة عرض كل المستخدمين في جدول
class AdminUsersWeb extends StatefulWidget {
  final void Function(Map<String, dynamic> user)? onOpen;
  const AdminUsersWeb({super.key, this.onOpen});

  @override
  State<AdminUsersWeb> createState() => _AdminUsersWebState();
}

class _AdminUsersWebState extends State<AdminUsersWeb> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final t = context.t;
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
        final hasMore = (state is AdminUsersLoaded) ? state.hasMore : false;

        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AdminSectionTitle('Users'),
              SizedBox(height: 16.h),
              TextField(
                onChanged: (v) {
                  _search = v;
                  context.read<AdminUsersCubit>().loadUsers(search: v.isEmpty ? null : v);
                },
                decoration: InputDecoration(
                  hintText: t.tr('search_users'),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
              ),
              SizedBox(height: 16.h),
              if (users.isEmpty)
                AdminEmptyState(icon: Icons.people_alt_outlined, message: t.tr('no_users'), onRetry: () => context.read<AdminUsersCubit>().loadUsers(search: _search.isEmpty ? null : _search))
              else ...[
                UsersTable(users, isCompact: MediaQuery.of(context).size.width <= 900, onOpen: widget.onOpen),
                if (hasMore)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: OutlinedButton.icon(
                        onPressed: () => context.read<AdminUsersCubit>().loadMoreUsers(search: _search.isEmpty ? null : _search),
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
