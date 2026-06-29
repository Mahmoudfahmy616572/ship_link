import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/views/shared/snackBar/snack_bar.dart';
import 'package:ship_link/views/user/screens/congrats/congrates.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebLocation extends StatelessWidget {
  const WebLocation({super.key, required this.url});
  final String url;
  static String routName = '/WebLocation';

  bool _isTrustedDomain(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.host.endsWith('spider-te8.com') || uri.host.endsWith('localhost');
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
      ..platform
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'messageHandler',
        onMessageReceived: (p0) {
          var data = jsonDecode(p0.message);
          if (data['success'] == false) {
            Navigator.pop(context);
          }
        },
      );
    return Scaffold(
      backgroundColor: const Color(0xFFCDCDCD),
      appBar: AppBar(),
      body: WebViewWidget(
          controller: webcontroller
            ..setNavigationDelegate(NavigationDelegate(
              onPageFinished: (url) async {
                await webcontroller
                    .runJavaScriptReturningResult(
                        "document.documentElement.innerText")
                    .then((value) {
                  var data = jsonDecode(value.toString());
                  if (data["success"] == 'true') {
                    Navigator.pushNamedAndRemoveUntil(
                        context, Congrates.routName, (route) => false);
                    CustomSnackBar.displaySuccessMotionToast(
                        context.t.tr('payment_successful'), context);
                  } else {
                    CustomSnackBar.displayErrorMotionToast(
                        context.t.tr('payment_failed'), context);
                  }
                });
              },
            ))),
    );
  }
}
