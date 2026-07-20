import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/presentation/cubits/users/admin_users_cubit.dart';
import 'package:ship_link/web/admin/presentation/cubits/admin_auth/admin_auth_cubit.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_stat_card.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_theme_mode.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_empty_state.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_toast.dart';
import 'package:ship_link/web/admin/presentation/screens/users/widgets/users_widgets.dart';
import 'package:ship_link/web/admin/presentation/screens/users/widgets/user_form_dialog.dart';

// شاشة عرض كل المستخدمين في جدول
class AdminUsersWeb extends StatefulWidget {
  final void Function(Map<String, dynamic> user)? onOpen;
  const AdminUsersWeb({super.key, this.onOpen});

  @override
  State<AdminUsersWeb> createState() => _AdminUsersWebState();
}

class _AdminUsersWebState extends State<AdminUsersWeb> {
  String _search = '';
  final Set<String> _selectedIds = {};
  bool _selectionMode = false;
  Timer? _searchTimer;

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  // البحث بيتأخر 300ms عشان منعملش طلب في كل حرف
  void _onSearchChanged(String v) {
    _search = v;
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 300), () => context.read<AdminUsersCubit>().loadUsers(search: v.isEmpty ? null : v));
  }

  void _toggle(String id) {
    if (id.isEmpty) return;
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _confirmBulkDelete() async {
    final t = context.t;
    final confirmed = await AdminConfirmDialog.show(
      context,
      title: t.tr('delete_selected'),
      message: '${t.tr('delete_selected_confirm')} (${_selectedIds.length})؟',
    );
    if (confirmed != true || !mounted) return;
    if (AdminAuthCubit.get(context).canViewOnly) {
      AdminToast.show(context, context.t.tr('no_access'));
      return;
    }
    final cubit = context.read<AdminUsersCubit>();
    for (final id in _selectedIds.toList()) {
      await cubit.deleteUser(id);
    }
  }

  // نفتح فورم إضافة/تعديل مستخدم (للأدمن بس)
  Future<void> _openForm(BuildContext context, Map<String, dynamic>? user) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => UserCreateEditDialog(user: user),
    );
    if (result == null || !mounted) return;
    final cubit = context.read<AdminUsersCubit>();
    if (user != null) {
      await cubit.updateUser(id: user['id'].toString(), data: result);
    } else {
      await cubit.createUser(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return BlocListener<AdminUsersCubit, dynamic>(
      listener: (context, state) {
        if (state is AdminUserDeleteSuccess) {
          AdminToast.show(context, t.tr('user_deleted'), type: AdminToastType.success);
          setState(() {
            _selectedIds.remove(state.id);
            if (_selectedIds.isEmpty) _selectionMode = false;
          });
          context.read<AdminUsersCubit>().loadUsers(search: _search.isEmpty ? null : _search);
        } else if (state is AdminUserCreateSuccess) {
          AdminToast.show(context, t.tr('user_created'), type: AdminToastType.success);
          context.read<AdminUsersCubit>().loadUsers(search: _search.isEmpty ? null : _search);
        } else if (state is AdminUserUpdateSuccess) {
          AdminToast.show(context, t.tr('user_updated'), type: AdminToastType.success);
          context.read<AdminUsersCubit>().loadUsers(search: _search.isEmpty ? null : _search);
        } else if (state is AdminUsersError) {
          AdminToast.show(context, state.message, type: AdminToastType.error);
        }
      },
      child: BlocBuilder<AdminUsersCubit, dynamic>(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AdminSectionTitle('Users', isDark: AdminThemeMode.isDark.value),
                    if (AdminAuthCubit.get(context).isSuperAdmin)
                      _selectionMode
                          ? Row(
                              children: [
                                TextButton.icon(
                                  key: const Key('cancel_sel'),
                                  onPressed: () => setState(() {
                                    _selectedIds.clear();
                                    _selectionMode = false;
                                  }),
                                  icon: const Icon(Icons.close, size: 18),
                                  label: Text(t.tr('cancel')),
                                ),
                                if (_selectedIds.isNotEmpty)
                                  ElevatedButton.icon(
                                    onPressed: _confirmBulkDelete,
                                    icon: const Icon(Icons.delete_outline, size: 18),
                                    label: Text('${t.tr('delete_selected')} (${_selectedIds.length})'),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                                  ),
                              ],
                            )
                          : Row(
                              children: [
                                TextButton.icon(
                                  key: const Key('select_btn'),
                                  onPressed: () => setState(() => _selectionMode = true),
                                  icon: const Icon(Icons.checklist, size: 18),
                                  label: Text(t.tr('select')),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _openForm(context, null),
                                  icon: const Icon(Icons.person_add, size: 18),
                                  label: Text(t.tr('add_user')),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                                ),
                              ],
                            ),
                  ],
                ),
                SizedBox(height: 16.h),
                TextField(
                onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: t.tr('search_users'),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  ),
                ),
                SizedBox(height: 16.h),
                if (users.isEmpty)
                  AdminEmptyState(icon: Icons.people_alt_outlined, message: t.tr('no_users'), onRetry: () => context.read<AdminUsersCubit>().loadUsers(search: _search.isEmpty ? null : _search), isDark: AdminThemeMode.isDark.value)
                else ...[
                  UsersTable(
                    users,
                    isCompact: MediaQuery.of(context).size.width <= 900,
                    onOpen: widget.onOpen,
                    isSelectionMode: _selectionMode,
                    selectedIds: _selectedIds,
                    onToggleSelect: _toggle,
                  ),
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
      ),
    );
  }
}
