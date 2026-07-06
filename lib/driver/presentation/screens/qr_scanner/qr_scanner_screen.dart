import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ship_link/core/utils/sizer.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key, required this.expectedOrderId, required this.onVerified});
  final String expectedOrderId;
  final VoidCallback onVerified;

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final _controller = MobileScannerController();
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) return;
    if (code.contains(widget.expectedOrderId)) {
      _done = true;
      _controller.stop();
      widget.onVerified();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Package QR')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: Text(
              'Scan the QR code on the package to confirm delivery.\nExpected order: #${widget.expectedOrderId}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
