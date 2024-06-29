// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../shared/snackBar/snack_bar.dart';

class MapWebViewScreen extends StatelessWidget {
  const MapWebViewScreen({super.key, required this.url});
  final String url;
  static String routName = '/mabWebView';
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
                  print('=================================');
                  var data = jsonDecode(value.toString());
                  var dataSp = jsonDecode(data);
                  print(dataSp["success"]);
                  if (dataSp["success"] == 'false') {
                    print('Faild');
                    Navigator.pop(context);
                    // Navigator.pushNamedAndRemoveUntil(
                    //     context, Congrates.routName, (route) => false);
                    CustomSnackBar.displaySuccessMotionToast(
                        "payment Successfuly", context);
                  } else if (dataSp["success"] != 'false') {
                    print('Success');
                    // Navigator.pushNamedAndRemoveUntil(
                    //     context, CheckOutPage.routName, (route) => false);
                    CustomSnackBar.displayErrorMotionToast(
                        "payment Successfuly", context);
                  }
                });
              },
            ))),
    );
  }
}
