import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tiketBus/pages/homepage.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/payment.dart';
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
  String? selectedBank;

  void _processPayment() async {
    if (selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih bank terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (widget.booking.id == null) {
        throw Exception('Invalid booking ID');
      }

      print('Processing payment for booking ID: ${widget.booking.id}');
      print('Amount: ${widget.booking.totalPrice}');
      print('Selected Bank: $selectedBank');

      final response = await _paymentService.createPayment(
        bookingId: widget.booking.id!,
        amount: widget.booking.totalPrice ?? 0,
        method: selectedBank!.toLowerCase(),
      );

      if (!mounted) return;

      if (response.error == null && response.data != null) {
        final payment = response.data as Payment;
        print('Payment created successfully. Payment ID: ${payment.id}');

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Pembayaran Berhasil'),
              content: const Text(
                'Pemesanan tiket Anda telah berhasil.\nTiket dapat dilihat di menu Tiket.',
                textAlign: TextAlign.center,
              ),
              actions: [
                Center(
                  child: TextButton(
                    onPressed: () {
                      widget.onPaymentComplete?.call();

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) =>
                              const HomePage1(initialIndex: 1),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text('OK'),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        throw Exception(response.error ?? 'Pembayaran gagal');
      }
    } catch (e) {
      print('Error processing payment: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ringkasan Pembayaran',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Pembayaran'),
                            Text(
                              'Rp ${NumberFormat('#,###').format(widget.booking.totalPrice ?? 0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pilih Metode Pembayaran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.account_balance),
                            const SizedBox(width: 8),
                            const Text(
                              'Transfer Bank',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildBankOption('BCA'),
                            _buildBankOption('BNI'),
                            _buildBankOption('Mandiri'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: isLoading ? null : _processPayment,
                    child: Text(
                      isLoading ? 'Memproses...' : 'Bayar Sekarang',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBankOption(String bankName) {
    final isSelected = selectedBank == bankName;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBank = bankName;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              bankName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.blue, size: 16),
          ],
        ),
      ),
    );
  }
}
