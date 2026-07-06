import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/user/presentation/cubits/confirmCart/confirm_cart_cubit.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/user/presentation/cubits/payment/payment_cubit.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/user/presentation/screens/checkOutPage/check_out.dart';
import 'package:ship_link/user/presentation/screens/congrats/congrates.dart';
import 'package:ship_link/core/services/cache_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebPage extends StatefulWidget {
  const WebPage({super.key, required this.url, required this.orderId});
  final String url;
  final int orderId;
  static String routName = '/WebPage';

  @override
  State<WebPage> createState() => _WebPageState();
}

class _PaymentWebViewState {
  final bool isLoading;
  final bool timedOut;
  final bool loadFailed;
  final int pollSeconds;
  final bool manualCheck;

  const _PaymentWebViewState({
    this.isLoading = true,
    this.timedOut = false,
    this.loadFailed = false,
    this.pollSeconds = 0,
    this.manualCheck = false,
  });

  _PaymentWebViewState copyWith({
    bool? isLoading,
    bool? timedOut,
    bool? loadFailed,
    int? pollSeconds,
    bool? manualCheck,
  }) {
    return _PaymentWebViewState(
      isLoading: isLoading ?? this.isLoading,
      timedOut: timedOut ?? this.timedOut,
      loadFailed: loadFailed ?? this.loadFailed,
      pollSeconds: pollSeconds ?? this.pollSeconds,
      manualCheck: manualCheck ?? this.manualCheck,
    );
  }
}

class _WebPageState extends State<WebPage> {
  InAppWebViewController? _controller;
  bool _paymentDone = false;
  final ValueNotifier<_PaymentWebViewState> _state = ValueNotifier(_PaymentWebViewState());
  bool _fromCheckout = false;
  static const _timeoutSeconds = 300;

  @override
  void initState() {
    super.initState();
    _fromCheckout = _hasProvider<ConfirmCartCubit>();
    _startPolling();
  }

  bool _hasProvider<T>() {
    try {
      context.read<T>();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _navigateOnPayment({bool success = true}) {
    if (_fromCheckout) {
      final cubit = context.read<ConfirmCartCubit>();
      final payment = context.read<PaymentCubit>();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: cubit),
              BlocProvider.value(value: payment),
            ],
            child: success
                ? Congrates(userEmail: Supabase.instance.client.auth.currentUser?.email)
                : const CheckOutPage(),
          ),
        ),
        (route) => false,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _handlePaymentSuccess() async {
    if (_paymentDone) return;
    _paymentDone = true;
    final supabase = Supabase.instance.client;
    final uid = supabase.auth.currentUser?.id;
    if (uid != null && _fromCheckout) {
      await supabase.from('cart_items').delete().eq('user_id', uid);
      await CacheService().remove('cart_$uid');
    }
    if (!mounted) return;
    _navigateOnPayment(success: true);
    if (_fromCheckout) {
      CustomSnackBar.displaySuccessMotionToast(
          context.t.tr('payment_successful'), context);
    }
  }

  Future<void> _checkStatus() async {
    _state.value = _state.value.copyWith(manualCheck: true);
    try {
      final supabase = Supabase.instance.client;
      final res = await supabase
          .from('orders')
          .select('paid_at, payment_error')
          .eq('id', widget.orderId)
          .maybeSingle();
      if (res != null) {
        if (res['paid_at'] != null) {
          await _handlePaymentSuccess();
        } else if (res['payment_error'] != null) {
          _paymentDone = true;
          final error = res['payment_error'] as String;
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text('Payment Failed'),
                content: Text(error),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _navigateOnPayment(success: false);
                    },
                    child: Text(_fromCheckout ? 'Back to Checkout' : 'Back'),
                  ),
                ],
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment not confirmed yet.')),
            );
          }
        }
      }
    } catch (_) {}
    if (mounted) _state.value = _state.value.copyWith(manualCheck: false);
  }

  Future<void> _startPolling() async {
    while (mounted && !_paymentDone && _state.value.pollSeconds < _timeoutSeconds) {
      await Future.delayed(const Duration(seconds: 3));
      _state.value = _state.value.copyWith(pollSeconds: _state.value.pollSeconds + 3);
      if (!mounted || _paymentDone) return;
      try {
        final supabase = Supabase.instance.client;
        final res = await supabase
            .from('orders')
            .select('paid_at, payment_error')
            .eq('id', widget.orderId)
            .maybeSingle();
        if (!mounted || _paymentDone) return;
        if (res != null) {
          if (res['paid_at'] != null) {
            await _handlePaymentSuccess();
          } else if (res['payment_error'] != null) {
            _paymentDone = true;
            final error = res['payment_error'] as String;
            if (mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => AlertDialog(
                  title: const Text('Payment Failed'),
                  content: Text(error),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _navigateOnPayment(success: false);
                      },
                      child: Text(_fromCheckout ? 'Back to Checkout' : 'Back'),
                    ),
                  ],
                ),
              );
            }
          }
        }
      } catch (_) {}
    }
    if (mounted && !_paymentDone) {
      _state.value = _state.value.copyWith(timedOut: true);
    }
  }

  @override
  void dispose() {
    _paymentDone = true;
    _controller = null;
    super.dispose();
  }

  Future<void> _reload() async {
    _state.value = _state.value.copyWith(timedOut: false, loadFailed: false, pollSeconds: 0);
    await _controller?.reload();
    _startPolling();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_PaymentWebViewState>(
      valueListenable: _state,
      builder: (_, st, __) {
        final theme = Theme.of(context);
        final elapsed = Duration(seconds: st.pollSeconds);
        final elapsedStr =
            '${elapsed.inMinutes}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';

        return Scaffold(
          appBar: AppBar(automaticallyImplyLeading: true),
          body: st.timedOut || st.loadFailed
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          st.timedOut ? Icons.timer_off : Icons.error_outline,
                          size: 48, color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          st.timedOut ? 'Payment timed out.' : 'Could not load payment page.',
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _reload,
                          child: const Text('Retry'),
                        ),
                        TextButton(
                          onPressed: () => _navigateOnPayment(success: false),
                          child: Text(_fromCheckout ? 'Back to Checkout' : 'Back'),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    InAppWebView(
                      initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                      initialSettings: InAppWebViewSettings(
                        javaScriptEnabled: true,
                        domStorageEnabled: true,
                        supportZoom: false,
                      ),
                      onWebViewCreated: (ctrl) {
                        _controller = ctrl;
                      },
                      onLoadStart: (ctrl, url) {
                        if (mounted) _state.value = _state.value.copyWith(isLoading: true);
                      },
                      onLoadStop: (ctrl, url) {
                        if (mounted) _state.value = _state.value.copyWith(isLoading: false);
                        if (!_paymentDone && url != null && url.toString().contains('paymob-callback')) {
                          final uri = Uri.parse(url.toString());
                          final success = uri.queryParameters['success'] == 'true';
                          final fullUrl = url.toString();
                          if (fullUrl.contains('paymob-callback') && uri.queryParameters.containsKey('success')) {
                            if (success) {
                              _handlePaymentSuccess();
                            } else {
                              _paymentDone = true;
                              if (mounted) {
                                final errorMsg = Uri.decodeComponent(uri.queryParameters['data.message'] ?? 'Payment failed');
                                CustomSnackBar.error(errorMsg, context);
                                _navigateOnPayment(success: false);
                              }
                            }
                          }
                        }
                      },
                      onReceivedError: (ctrl, request, error) {
                        if (mounted && !_paymentDone) _state.value = _state.value.copyWith(loadFailed: true);
                      },
                      shouldOverrideUrlLoading: (ctrl, navigationAction) async {
                        final url = navigationAction.request.url.toString();
                        if (url.contains('paymob-callback') && navigationAction.isForMainFrame) {
                          return NavigationActionPolicy.ALLOW;
                        }
                        return NavigationActionPolicy.ALLOW;
                      },
                    ),
                    if (st.isLoading)
                      const Center(child: CircularProgressIndicator()),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(
                            onPressed: st.manualCheck ? null : _checkStatus,
                            icon: st.manualCheck
                                ? const SizedBox(
                                    width: 14, height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.refresh, size: 18),
                            label: Text(st.manualCheck ? '...' : 'Check Status'),
                          ),
                          Text(
                            elapsedStr,
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
