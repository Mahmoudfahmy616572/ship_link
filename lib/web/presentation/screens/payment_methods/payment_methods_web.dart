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
    _loading = true;
    if (mounted) setState(() {});
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
          _methods = List<Map<String, dynamic>>.from(data);
        }
      }
    } catch (_) {}
    if (mounted) { _loading = false; setState(() {}); }
  }

  Future<void> _addCard() async {
    _addingCard = true;
    if (mounted) setState(() {});
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return;
      var origin = Uri.base.origin;
      if (origin.startsWith('http://')) {
        origin = origin.replaceFirst('http://', 'https://');
      }
      final result = await Supabase.instance.client.functions.invoke(
        'paymob-add-card',
        body: {'userId': uid, 'redirectUri': '$origin/payment-methods'},
      );
      final data = (result as dynamic).data as Map<String, dynamic>?;
      final url = data?['url'] as String?;
      if (url == null) {
        if (mounted) _showSnack(context.t.tr('failed_card_setup'));
        return;
      }
      final secureUrl = url.replaceFirst('http://', 'https://');
      html.window.open(secureUrl, 'paymob_add_card');
      if (mounted) {
        _showSnack(context.t.tr('complete_card_setup'));
      }
    } catch (e) {
      final msg = e.toString();
      if (mounted) _showSnack(msg.contains('fetch') ? context.t.tr('payment_network_error') : msg);
    } finally {
      if (mounted) { _addingCard = false; setState(() {}); }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(context.t.tr('payment_methods'), style: appStyle(18, FontWeight.w600, const Color(0xFF111827))),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _methods.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.credit_card_outlined, size: 64, color: const Color(0xFFD1D5DB)),
                      SizedBox(height: 16),
                      Text(context.t.tr('no_payment_methods'), style: appStyle(16, FontWeight.w500, const Color(0xFF6B7280))),
                      SizedBox(height: 8),
                      Text(context.t.tr('add_card_hint'), style: appStyle(14, FontWeight.w400, const Color(0xFFD1D5DB))),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      color: Colors.white,
                      child: ListTile(
                        leading: Icon(Icons.credit_card, size: 28, color: AppColors.primary),
                        title: Text('${_brandLabel(brand)} •••• $lastFour',
                            style: appStyle(15, FontWeight.w600, const Color(0xFF111827))),
                        subtitle: isDefault
                            ? Text(context.t.tr('default'), style: appStyle(13, FontWeight.w500, AppColors.primary))
                            : null,
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'default') _setDefault(id);
                            if (v == 'delete') _delete(id);
                          },
                          itemBuilder: (_) => [
                            if (!isDefault)
                              PopupMenuItem(value: 'default', child: Text(context.t.tr('set_default'))),
                            PopupMenuItem(value: 'delete', child: Text(context.t.tr('delete'), style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addingCard ? null : _addCard,
        backgroundColor: AppColors.cta,
        foregroundColor: Colors.white,
        icon: _addingCard
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.add),
        label: Text(context.t.tr('add_card')),
      ),
    );
  }

  String _brandLabel(String brand) => brand.isEmpty ? 'Card' : brand;
}
