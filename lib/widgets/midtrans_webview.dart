import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransWebView extends StatefulWidget {
  final String snapToken;
  final VoidCallback onPaymentSuccess;
  final VoidCallback onPaymentPending;
  final VoidCallback onPaymentFailed;

  const MidtransWebView({
    Key? key,
    required this.snapToken,
    required this.onPaymentSuccess,
    required this.onPaymentPending,
    required this.onPaymentFailed,
  }) : super(key: key);

  @override
  State<MidtransWebView> createState() => _MidtransWebViewState();
}

class _MidtransWebViewState extends State<MidtransWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.contains('transaction_status=settlement') ||
                request.url.contains('transaction_status=capture')) {
              widget.onPaymentSuccess();
              return NavigationDecision.prevent;
            } else if (request.url.contains('transaction_status=pending')) {
              widget.onPaymentPending();
              return NavigationDecision.prevent;
            } else if (request.url.contains('transaction_status=deny') ||
                request.url.contains('transaction_status=cancel') ||
                request.url.contains('transaction_status=expire')) {
              widget.onPaymentFailed();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
            'https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.snapToken}'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
