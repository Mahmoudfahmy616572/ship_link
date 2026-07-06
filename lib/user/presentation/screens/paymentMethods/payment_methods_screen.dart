import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/user/data/repositories/payment_methods_repository_impl.dart';
import 'package:ship_link/user/presentation/screens/paymentWebView/payment_web_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});
  static String routName = '/paymentMethods';
  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _service = PaymentMethodsRepositoryImpl();
  final ValueNotifier<List<Map<String, dynamic>>> _methods = ValueNotifier([]);
  final ValueNotifier<bool> _loading = ValueNotifier(true);
  final ValueNotifier<bool> _addingCard = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _loading.value = true;
    try {
      final data = (await _service.getAll()).fold((_) => <Map<String, dynamic>>[], (v) => v);
      if (mounted) { _methods.value = data; _loading.value = false; }
    } catch (_) {
      if (mounted) _loading.value = false;
    }
  }

  Future<void> _addCard() async {
    _addingCard.value = true;
    try {
      final supabase = Supabase.instance.client;
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) return;
      final result = await supabase.functions.invoke(
        'paymob-add-card',
        body: {'userId': uid, 'redirectUri': 'com.example.ship_link.user://add-card'},
      );
      final data = (result as dynamic).data as Map<String, dynamic>;
      final url = data['url'] as String?;
      final orderId = data['orderId'] as int?;
      if (url == null || url.isEmpty || orderId == null) {
        if (mounted) CustomSnackBar.displayErrorMotionToast('Failed to start card setup', context);
        return;
      }
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WebPage(url: url, orderId: orderId),
        ),
      );
      _load();
    } catch (e) {
      if (mounted) CustomSnackBar.displayErrorMotionToast(e.toString(), context);
    } finally {
      if (mounted) _addingCard.value = false;
    }
  }

  Future<void> _setDefault(String id) async {
    await _service.setDefault(id);
    _load();
  }

  Future<void> _delete(String id) async {
    await _service.delete(id);
    _load();
  }

  String _cardIcon(String brand) {
    final b = brand.toLowerCase();
    if (b.contains('visa')) return '💳';
    if (b.contains('master')) return '💳';
    return '💳';
  }

  String _brandLabel(String brand) {
    if (brand.isEmpty) return 'Card';
    return brand;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.tr('payment_methods'))),
      body: ValueListenableBuilder<bool>(
        valueListenable: _loading,
        builder: (_, loading, __) {
          if (loading) return const Center(child: CircularProgressIndicator());
          return ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: _methods,
            builder: (_, methods, __) => methods.isEmpty ? _emptyState() : _cardList(),
          );
        },
      ),
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _addingCard,
        builder: (_, addingCard, __) => FloatingActionButton.extended(
          onPressed: addingCard ? null : _addCard,
          icon: addingCard
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.add),
          label: Text('Add Card'),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card_outlined, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16.h),
          Text('No saved payment methods', style: appStyle(16, FontWeight.w500, AppColors.textSecondary)),
          SizedBox(height: 8.h),
          Text('Add a card to pay faster next time', style: appStyle(14, FontWeight.w400, AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _cardList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _methods.value.length,
      itemBuilder: (ctx, i) {
        final card = _methods.value[i];
        final id = card['id'] as String;
        final lastFour = card['last_four'] as String? ?? '****';
        final brand = card['card_brand'] as String? ?? '';
        final isDefault = card['is_default'] as bool? ?? false;
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          child: ListTile(
            leading: Text(_cardIcon(brand), style: const TextStyle(fontSize: 28)),
            title: Text('${_brandLabel(brand)} •••• $lastFour'),
            subtitle: isDefault ? Text('Default', style: TextStyle(color: AppColors.primary, fontSize: 12)) : null,
            trailing: PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'default') _setDefault(id);
                if (v == 'delete') _delete(id);
              },
              itemBuilder: (_) => [
                if (!isDefault)
                  const PopupMenuItem(value: 'default', child: Text('Set as default')),
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        );
      },
    );
  }
}
