import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/presentation/cubits/products/admin_products_cubit.dart';
import 'package:ship_link/web/admin/presentation/cubits/admin_auth/admin_auth_cubit.dart';
import 'package:ship_link/web/admin/domain/models/admin_models.dart';
import 'package:ship_link/web/data/services_locators.dart';
import 'package:ship_link/web/admin/presentation/screens/products/widgets/product_form_dialog.dart';
import 'package:ship_link/web/admin/presentation/screens/products/widgets/products_widgets.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_empty_state.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_toast.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_theme_mode.dart';

// شاشة المنتجات - عرض + بحث + إضافة/تعديل/حذف
class AdminProductsWeb extends StatefulWidget {
  final void Function(AdminProduct product)? onOpen;
  const AdminProductsWeb({super.key, this.onOpen});

  @override
  State<AdminProductsWeb> createState() => _AdminProductsWebState();
}

class _AdminProductsWebState extends State<AdminProductsWeb> {
  String _search = '';
  String? _category;
  String _sortBy = 'created_at';
  bool _ascending = false;
  final Set<int> _selectedIds = {};
  bool _selectionMode = false;
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    getIt<AdminProductsCubit>().loadCategories();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  // البحث بيتأخر 300ms عشان منعملش طلب في كل حرف
  void _onSearchChanged(String v) {
    _search = v;
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 300), () => _reload());
  }

  void _reload() {
    final search = _search.isEmpty ? null : _search;
    getIt<AdminProductsCubit>().loadProducts(search: search, category: _category, sortBy: _sortBy, ascending: _ascending);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final cubit = getIt<AdminProductsCubit>();
    return BlocProvider.value(
      value: cubit,
      child: BlocListener<AdminProductsCubit, dynamic>(
      listener: (context, state) {
        if (state is AdminProductSaveSuccess) {
          AdminToast.show(context, t.tr('product_saved'), type: AdminToastType.success);
          _reload();
        } else if (state is AdminProductDeleteSuccess) {
          AdminToast.show(context, t.tr('product_deleted'), type: AdminToastType.success);
          setState(() {
            _selectedIds.clear();
            _selectionMode = false;
          });
          _reload();
        } else if (state is AdminProductsBulkDeleteSuccess) {
          AdminToast.show(context, '${t.tr('products_deleted')} (${state.count})', type: AdminToastType.success);
          setState(() {
            _selectedIds.clear();
            _selectionMode = false;
          });
          _reload();
        } else if (state is AdminProductsError) {
          AdminToast.show(context, state.message, type: AdminToastType.error);
        }
      },
      child: BlocBuilder<AdminProductsCubit, dynamic>(
        builder: (context, state) {
          if (state is AdminProductsInitial) {
            context.read<AdminProductsCubit>().loadProducts(category: _category, sortBy: _sortBy, ascending: _ascending);
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminProductsLoading) {
            return const ProductsTableShimmer();
          }
          if (state is AdminProductsError) {
            return ProductsErrorView(state.message);
          }
          final products = (state is AdminProductsLoaded) ? state.products : <AdminProduct>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(t.tr('products'), style: appStyle(22, FontWeight.w700, AdminThemeMode.textPrimary(AdminThemeMode.isDark.value))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                          child: Text('ROLE=${AdminAuthCubit.get(context).adminRole}', style: appStyle(12, FontWeight.w700, Colors.white)),
                        ),
                        const SizedBox(width: 12),
                    if (!_selectionMode && AdminAuthCubit.get(context).isSuperAdmin)
                      TextButton.icon(
                        onPressed: () => setState(() => _selectionMode = true),
                        icon: const Icon(Icons.checklist, size: 18),
                        label: Text(t.tr('select')),
                      )
                    else if (_selectionMode) ...[
                      TextButton.icon(
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
                      ],
                    ),
                    if (!_selectionMode && AdminAuthCubit.get(context).isSuperAdmin)
                      ElevatedButton.icon(
                        onPressed: () {
                          if (!_guard(context)) return;
                          _openForm(context, null);
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(t.tr('add_product')),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      ),
                  ],
                ),
                SizedBox(height: 16.h),
                TextField(
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: t.tr('search_products'),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _category,
                        decoration: InputDecoration(
                          hintText: t.tr('category'),
                          prefixIcon: const Icon(Icons.filter_list),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        ),
                        items: [
                          DropdownMenuItem<String>(value: null, child: Text(t.tr('all_categories'))),
                          ...cubit.categories.map((c) => DropdownMenuItem<String>(value: c, child: Text(c))),
                        ],
                        onChanged: (v) {
                          setState(() => _category = v);
                          _reload();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    _SortChip(label: t.tr('date'), active: _sortBy == 'created_at', onTap: () { setState(() { _sortBy = 'created_at'; _ascending = false; }); _reload(); }),
                    _SortChip(label: t.tr('price'), active: _sortBy == 'price', ascending: _ascending, onTap: () { setState(() { _sortBy = 'price'; _ascending = !(_sortBy == 'price' && _ascending); }); _reload(); }),
                    _SortChip(label: t.tr('name'), active: _sortBy == 'name', ascending: _ascending, onTap: () { setState(() { _sortBy = 'name'; _ascending = !(_sortBy == 'name' && _ascending); }); _reload(); }),
                  ],
                ),
                SizedBox(height: 16.h),
                if (products.isEmpty)
                  AdminEmptyState(icon: Icons.inventory_2_outlined, message: t.tr('no_products'), onRetry: () => _reload(), isDark: AdminThemeMode.isDark.value)
                else ...[
                  ProductsTable(
                    products,
                    isCompact: MediaQuery.of(context).size.width <= 900,
                    onEdit: (p) => _openForm(context, p),
                    onDelete: (p) => _confirmDelete(context, p),
                    onOpen: widget.onOpen,
                    onToggleStatus: AdminAuthCubit.get(context).isSuperAdmin
                        ? (p) async {
                            if (!_guard(context)) return;
                            await getIt<AdminProductsCubit>().toggleStatus(p.id!, p.status);
                            AdminToast.show(context, t.tr('status_updated'), type: AdminToastType.success);
                          }
                        : null,
                    canManage: AdminAuthCubit.get(context).isSuperAdmin,
                    isSelectionMode: _selectionMode,
                    selectedIds: _selectedIds,
                    onToggleSelect: (id) {
                      if (id < 0) return;
                      setState(() {
                        if (_selectedIds.contains(id)) {
                          _selectedIds.remove(id);
                          if (_selectedIds.isEmpty) _selectionMode = false;
                        } else {
                          _selectedIds.add(id);
                        }
                      });
                    },
                  ),
                  if (state is AdminProductsLoaded && state.hasMore)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Center(
                        child: OutlinedButton.icon(
                          onPressed: () => context.read<AdminProductsCubit>().loadMoreProducts(search: _search.isEmpty ? null : _search),
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
      ),
    );
  }

  Future<void> _openForm(BuildContext context, AdminProduct? product) async {
    if (!_guard(context)) return;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => ProductFormDialog(product: product),
    );
    if (result == null || !mounted) return;
    final id = product?.id;
    if (id is int) {
      context.read<AdminProductsCubit>().updateProduct(id: id, data: result);
    } else {
      context.read<AdminProductsCubit>().createProduct(result);
    }
  }

  Future<void> _confirmBulkDelete() async {
    final t = context.t;
    final confirmed = await AdminConfirmDialog.show(
      context,
      title: t.tr('delete_selected'),
      message: '${t.tr('delete_selected_confirm')} (${_selectedIds.length})؟',
    );
    if (confirmed != true || !mounted) return;
    if (!_guard(context)) return;
    context.read<AdminProductsCubit>().deleteProductsBulk(_selectedIds.toList());
  }

  Future<void> _confirmDelete(BuildContext context, AdminProduct p) async {
    final t = context.t;
    final confirmed = await AdminConfirmDialog.show(
      context,
      title: t.tr('delete_product'),
      message: '${t.tr('delete_product_confirm')} "${p.name ?? ''}"؟',
    );
    if (confirmed != true || !mounted) return;
    if (!_guard(context)) return;
    final id = p.id;
    if (id is int) context.read<AdminProductsCubit>().deleteProduct(id);
  }

  // نحمي الـ viewer: أي محاولة كتابة تطلع توست وتمنع
  bool _guard(BuildContext context) {
    if (AdminAuthCubit.get(context).canViewOnly) {
      AdminToast.show(context, context.t.tr('no_access'));
      return false;
    }
    return true;
  }
}

// شيب الترتيب (السعر/التاريخ/الاسم) مع اتجاه تصاعدي/تنازلية
class _SortChip extends StatelessWidget {
  final String label;
  final bool active;
  final bool ascending;
  final VoidCallback onTap;
  const _SortChip({required this.label, required this.active, this.ascending = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (active) Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
          ],
        ),
        selected: active,
        onSelected: (_) => onTap(),
        backgroundColor: AdminThemeMode.surface(AdminThemeMode.isDark.value),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: appStyle(13, FontWeight.w600, active ? AppColors.primary : AdminThemeMode.textSecondary(AdminThemeMode.isDark.value)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AdminThemeMode.border(AdminThemeMode.isDark.value))),
      ),
    );
  }
}
