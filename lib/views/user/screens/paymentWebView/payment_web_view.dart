import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ship_link/views/shared/snackBar/snack_bar.dart';
import 'package:ship_link/views/user/screens/congrats/congrates.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPage extends StatelessWidget {
  const WebPage({super.key, required this.url});
  final String url;
  static String routName = '/WebPage';

  @override
  Widget build(BuildContext context) {
    Uri urls = Uri.parse(url);
    var webcontroller = WebViewController()
      ..loadRequest(urls)
      ..platform
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'messageHandler',
        onMessageReceived: (p0) {
          print(p0);
          var data = jsonDecode(p0.message);
          print(data['success']);
          if (data['success'] == false) {
            Navigator.pushReplacementNamed(context, Congrates.routName);
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
                  print('=================================');
                  var data = jsonDecode(value.toString());
                  var dataSp = jsonDecode(data);
                  print(dataSp["success"]);
                  if (dataSp["success"] == 'false') {
                    print('======');
                    Navigator.pushReplacementNamed(context, Congrates.routName);
                    CustomSnackBar.displayErrorMotionToast(
                        "payment Faild,please try again Later", context);
                  } else if (dataSp["success"] != 'false') {
                    print('======');
                    Navigator.pushReplacementNamed(context, Congrates.routName);
                    CustomSnackBar.displaySuccessMotionToast(
                        "payment Successfuly", context);
                  }
                });
              },
            ))),
    );
  }
}
