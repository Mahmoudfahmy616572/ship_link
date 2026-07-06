import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentMethodsWeb extends StatefulWidget {
  const PaymentMethodsWeb({super.key});
  static String routName = '/paymentMethods';

  @override
  State<PaymentMethodsWeb> createState() => _PaymentMethodsWebState();
}

class _PaymentMethodsWebState extends State<PaymentMethodsWeb> {
  List<Map<String, dynamic>> _methods = [];
  bool _loading = true;
  bool _addingCard = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid != null) {
        final data = await Supabase.instance.client
            .from('payment_methods')
            .select()
            .eq('user_id', uid)
            .order('is_default', ascending: false)
            .order('created_at', ascending: false);
        if (mounted) {
          setState(() => _methods = List<Map<String, dynamic>>.from(data));
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _addCard() async {
    setState(() => _addingCard = true);
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return;
      final origin = Uri.base.origin;
      final result = await Supabase.instance.client.functions.invoke(
        'paymob-add-card',
        body: {'userId': uid, 'redirectUri': '$origin/payment-methods'},
      );
      final data = (result as dynamic).data as Map<String, dynamic>;
      final url = data['url'] as String?;
      if (url == null) {
        if (mounted) _showSnack('Failed to start card setup');
        return;
      }
      html.window.open(url, 'paymob_add_card');
      if (mounted) {
        _showSnack('Complete card setup in the new tab, then come back here');
      }
    } catch (e) {
      if (mounted) _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _addingCard = false);
    }
  }

  Future<void> _setDefault(String id) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    await Supabase.instance.client
        .from('payment_methods')
        .update({'is_default': false})
        .eq('user_id', uid);
    await Supabase.instance.client
        .from('payment_methods')
        .update({'is_default': true})
        .eq('id', id);
    _load();
  }

  Future<void> _delete(String id) async {
    await Supabase.instance.client.from('payment_methods').delete().eq('id', id);
    _load();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _brandLabel(String brand) => brand.isEmpty ? 'Card' : brand;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.tr('payment_methods'))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _methods.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.credit_card_outlined, size: 64, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text('No saved payment methods', style: appStyle(16, FontWeight.w500, AppColors.textSecondary)),
                      SizedBox(height: 8),
                      Text('Add a card to pay faster next time', style: appStyle(14, FontWeight.w400, AppColors.textSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _methods.length,
                  itemBuilder: (ctx, i) {
                    final card = _methods[i];
                    final id = card['id'] as String;
                    final lastFour = card['last_four'] as String? ?? '****';
                    final brand = card['card_brand'] as String? ?? '';
                    final isDefault = card['is_default'] == true;
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.credit_card, size: 28),
                        title: Text('${_brandLabel(brand)} •••• $lastFour'),
                        subtitle: isDefault ? Text('Default', style: TextStyle(color: AppColors.primary)) : null,
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
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addingCard ? null : _addCard,
        icon: _addingCard
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.add),
        label: const Text('Add Card'),
      ),
    );
  }
}
