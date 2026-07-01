import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/cubits/confirmCart/confirm_cart_cubit.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/cubits/payment/payment_cubit.dart';
import 'package:ship_link/views/shared/snackBar/snack_bar.dart';
import 'package:ship_link/views/user/screens/checkOutPage/check_out.dart';
import 'package:ship_link/views/user/screens/congrats/congrates.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class WebPage extends StatefulWidget {
  const WebPage({super.key, required this.url, required this.orderId});
  final String url;
  final int orderId;
  static String routName = '/WebPage';

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  bool _paymentDone = false;
  bool _launchFailed = false;

  Future<void> _launchUrl() async {
    final uri = Uri.tryParse(widget.url);
    if (uri == null) return;
    try {
      final launched = await launchUrl(uri);
      if (!launched) {
        if (mounted) setState(() => _launchFailed = true);
      }
    } catch (e) {
      debugPrint('launchUrl error: $e');
      if (mounted) setState(() => _launchFailed = true);
    }
  }

  Future<void> _pollOrderStatus() async {
    while (mounted && !_paymentDone) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted || _paymentDone) return;
      try {
        final supabase = Supabase.instance.client;
        final res = await supabase
            .from('orders')
            .select('paid_at')
            .eq('id', widget.orderId)
            .maybeSingle();
        if (!mounted || _paymentDone) return;
        if (res != null && res['paid_at'] != null) {
          _paymentDone = true;
          final uid = supabase.auth.currentUser?.id;
          if (uid != null) {
            await supabase.from('cart_items').delete().eq('user_id', uid);
          }
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: context.read<ConfirmCartCubit>()),
                  BlocProvider.value(value: context.read<PaymentCubit>()),
                ],
                child: Congrates(
                  userEmail: supabase.auth.currentUser?.email,
                ),
              ),
            ),
            (route) => false,
          );
          CustomSnackBar.displaySuccessMotionToast(
              context.t.tr('payment_successful'), context);
        }
      } catch (_) {}
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _launchUrl());
    _pollOrderStatus();
  }

  @override
  void dispose() {
    _paymentDone = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_launchFailed) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  'Opening browser for payment...',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Waiting for payment confirmation...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
                const SizedBox(height: 16),
                Text(
                  'Could not open browser automatically',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please open the link manually:',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    widget.url,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _launchUrl,
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Try Again'),
                ),
              ],
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: context.read<ConfirmCartCubit>()),
                        BlocProvider.value(value: context.read<PaymentCubit>()),
                      ],
                      child: const CheckOutPage(),
                    ),
                  ),
                  (route) => false,
                ),
                child: const Text('Back to Checkout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
