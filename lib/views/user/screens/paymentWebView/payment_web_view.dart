import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/cubits/confirmCart/confirm_cart_cubit.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/cubits/payment/payment_cubit.dart';
import 'package:ship_link/views/shared/snackBar/snack_bar.dart';
import 'package:ship_link/views/user/screens/checkOutPage/check_out.dart';
import 'package:ship_link/views/user/screens/congrats/congrates.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPage extends StatelessWidget {
  const WebPage({super.key, required this.url});
  final String url;
  static String routName = '/WebPage';

  bool _isTrustedDomain(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.host.endsWith('spider-te8.com') ||
        uri.host.endsWith('localhost') ||
        uri.host.endsWith('paymob.com') ||
        uri.host.endsWith('supabase.co');
  }

  @override
  Widget build(BuildContext context) {
    if (!_isTrustedDomain(url)) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Untrusted URL')),
      );
    }
    Uri urls = Uri.parse(url);
    var webcontroller = WebViewController()
      ..loadRequest(urls)
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 33, 26, 26),
      appBar: AppBar(),
      body: WebViewWidget(
          controller: webcontroller
            ..setNavigationDelegate(NavigationDelegate(
              onPageFinished: (pageUrl) async {
                // First check URL query params (works regardless of redirect target)
                final uri = Uri.tryParse(pageUrl);
                debugPrint('WebView page loaded: $pageUrl');
                debugPrint('WebView query params: ${uri?.queryParameters}');
                if (uri != null && uri.queryParameters.containsKey('success')) {
                  final raw = uri.queryParameters['success']!;
                  final isSuccess = raw == 'true' || raw == '1';
                  debugPrint('WebView detected success via URL: $isSuccess (raw=$raw)');
                  if (isSuccess) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: context.read<ConfirmCartCubit>()),
                            BlocProvider.value(value: context.read<PaymentCubit>()),
                          ],
                          child: Congrates(
                            userEmail: Supabase
                                .instance.client.auth.currentUser?.email,
                          ),
                        ),
                      ),
                      (route) => false,
                    );
                    CustomSnackBar.displaySuccessMotionToast(
                        context.t.tr('payment_successful'), context);
                  } else {
                    Navigator.pushAndRemoveUntil(
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
                    );
                    CustomSnackBar.displayErrorMotionToast(
                        context.t.tr('payment_failed'), context);
                  }
                  return;
                }
                // Fallback: try parsing page content as JSON
                await webcontroller
                    .runJavaScriptReturningResult(
                        "document.documentElement.innerText")
                    .then((value) {
                  debugPrint('WebView innerText: $value');
                  dynamic decoded;
                  try {
                    decoded = jsonDecode(value.toString());
                  } catch (_) {
                    debugPrint('WebView JSON parse failed (not JSON)');
                    return;
                  }
                  bool isSuccess = false;
                  if (decoded is Map) {
                    var successVal = decoded["success"];
                    isSuccess = successVal == true || successVal == "true";
                    debugPrint('WebView JSON map: success=$successVal -> isSuccess=$isSuccess');
                  } else if (decoded is List && decoded.isNotEmpty) {
                    var first = decoded[0];
                    if (first is Map) {
                      var successVal = first["success"];
                      isSuccess = successVal == true || successVal == "true";
                      debugPrint('WebView JSON list[0]: success=$successVal -> isSuccess=$isSuccess');
                    }
                  }
                  if (isSuccess) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: context.read<ConfirmCartCubit>()),
                            BlocProvider.value(value: context.read<PaymentCubit>()),
                          ],
                          child: Congrates(
                            userEmail: Supabase
                                .instance.client.auth.currentUser?.email,
                          ),
                        ),
                      ),
                      (route) => false,
                    );
                    CustomSnackBar.displaySuccessMotionToast(
                        context.t.tr('payment_successful'), context);
                  } else {
                    Navigator.pushAndRemoveUntil(
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
                    );
                    CustomSnackBar.displayErrorMotionToast(
                        context.t.tr('payment_failed'), context);
                  }
                });
              },
            ))),
    );
  }
}
