import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/presentation/cubits/products/admin_products_cubit.dart';
import 'package:ship_link/web/admin/presentation/screens/products/widgets/product_form_dialog.dart';
import 'package:ship_link/web/admin/presentation/screens/products/widgets/products_widgets.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_toast.dart';

// شاشة المنتجات - عرض + بحث + إضافة/تعديل/حذف
class AdminProductsWeb extends StatefulWidget {
  const AdminProductsWeb({super.key});

  @override
  State<AdminProductsWeb> createState() => _AdminProductsWebState();
}

class _AdminProductsWebState extends State<AdminProductsWeb> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return BlocListener<AdminProductsCubit, dynamic>(
      listener: (context, state) {
        if (state is AdminProductSaveSuccess) {
          AdminToast.show(context, t.tr('product_saved'), type: AdminToastType.success);
          context.read<AdminProductsCubit>().loadProducts(search: _search.isEmpty ? null : _search);
        } else if (state is AdminProductDeleteSuccess) {
          AdminToast.show(context, t.tr('product_deleted'), type: AdminToastType.success);
          context.read<AdminProductsCubit>().loadProducts(search: _search.isEmpty ? null : _search);
        } else if (state is AdminProductsError) {
          AdminToast.show(context, state.message, type: AdminToastType.error);
        }
      },
      child: BlocBuilder<AdminProductsCubit, dynamic>(
        builder: (context, state) {
          if (state is AdminProductsInitial) {
            context.read<AdminProductsCubit>().loadProducts();
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminProductsLoading) {
            return const ProductsTableShimmer();
          }
          if (state is AdminProductsError) {
            return ProductsErrorView(state.message);
          }
          final products = (state is AdminProductsLoaded) ? state.products : <Map<String, dynamic>>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t.tr('products'), style: appStyle(22, FontWeight.w700, AppColors.textPrimary)),
                    ElevatedButton.icon(
                      onPressed: () => _openForm(context, null),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(t.tr('add_product')),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                TextField(
                  onChanged: (v) {
                    _search = v;
                    context.read<AdminProductsCubit>().loadProducts(search: v.isEmpty ? null : v);
                  },
                  decoration: InputDecoration(
                    hintText: t.tr('search_products'),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  ),
                ),
                SizedBox(height: 16.h),
                if (products.isEmpty)
                  Center(child: Padding(padding: const EdgeInsets.all(40), child: Text(t.tr('no_products'), style: appStyle(15, FontWeight.w500, AppColors.textSecondary))))
                else
                  ProductsTable(
                    products,
                    isCompact: MediaQuery.of(context).size.width <= 900,
                    onEdit: (p) => _openForm(context, p),
                    onDelete: (p) => _confirmDelete(context, p),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openForm(BuildContext context, Map<String, dynamic>? product) async {
    final t = context.t;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => ProductFormDialog(product: product),
    );
    if (result == null || !mounted) return;
    final id = product?['id'];
    if (id is int) {
      context.read<AdminProductsCubit>().updateProduct(id: id, data: result);
    } else {
      context.read<AdminProductsCubit>().createProduct(result);
    }
  }

  Future<void> _confirmDelete(BuildContext context, Map<String, dynamic> p) async {
    final t = context.t;
    final confirmed = await AdminConfirmDialog.show(
      context,
      title: t.tr('delete_product'),
      message: '${t.tr('delete_product_confirm')} "${p['name']?.toString() ?? ''}"؟',
    );
    if (confirmed != true || !mounted) return;
    final id = p['id'];
    if (id is int) context.read<AdminProductsCubit>().deleteProduct(id);
  }
}
