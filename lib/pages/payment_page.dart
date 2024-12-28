import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/payment_service.dart';
import '../widgets/midtrans_webview.dart';

class PaymentPage extends StatefulWidget {
  final dynamic booking;
  final VoidCallback onPaymentComplete;

  const PaymentPage({
    Key? key,
    required this.booking,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final PaymentService _paymentService = PaymentService();
  bool isLoading = false;

  void _processPayment() async {
    setState(() => isLoading = true);

    try {
      print('Processing payment for booking ID: ${widget.booking.id}');

      final response = await _paymentService.createPayment(
        bookingId: widget.booking.id!,
        amount: widget.booking.totalPrice!,
        method: 'bank_transfer',
      );

      if (response.error != null) {
        throw Exception(response.error);
      }

      if (mounted) {
        final paymentData = response.data as Map<String, dynamic>;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MidtransWebView(
              snapToken: paymentData['snap_token'],
              onPaymentSuccess: () {
                widget.onPaymentComplete();
                Navigator.of(context).pushReplacementNamed('/home');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pembayaran berhasil'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              onPaymentPending: () {
                Navigator.of(context)
                    .pushReplacementNamed('/payment-instructions');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Silakan selesaikan pembayaran Anda'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              onPaymentFailed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pembayaran gagal'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tampilkan detail booking
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Pemesanan',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Total Pembayaran: Rp ${widget.booking.totalPrice}'),
                    // Tambahkan detail lainnya sesuai kebutuhan
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Bayar Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
