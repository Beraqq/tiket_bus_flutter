import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../models/payment.dart';
import '../services/payment_service.dart';
import 'pages/payment_instruction_page.dart';

class PaymentPage extends StatefulWidget {
  final Booking booking;
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
  String? selectedPaymentMethod;
  bool isLoading = false;

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'id': 'bank_transfer',
      'name': 'Transfer Bank',
      'icon': Icons.account_balance,
      'banks': ['BCA', 'BNI', 'Mandiri', 'BRI'],
    },
    {
      'id': 'virtual_account',
      'name': 'Virtual Account',
      'icon': Icons.credit_card,
      'banks': ['BCA', 'BNI', 'Mandiri', 'BRI'],
    },
    {
      'id': 'e_wallet',
      'name': 'E-Wallet',
      'icon': Icons.wallet,
      'providers': ['GoPay', 'OVO', 'DANA', 'LinkAja'],
    },
  ];

  void _processPayment() async {
    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih metode pembayaran'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await _paymentService.createPayment(
        bookingId: widget.booking.bookingId!,
        amount: widget.booking.totalPrice!,
        method: selectedPaymentMethod!,
      );

      if (response.error != null) {
        throw Exception(response.error);
      }

      if (mounted) {
        widget.onPaymentComplete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran berhasil'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memproses pembayaran: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaymentSummary(),
            const SizedBox(height: 24),
            _buildPaymentMethods(),
            const SizedBox(height: 24),
            _buildPaymentButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  'Rp ${NumberFormat('#,###').format(widget.booking.totalPrice)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Metode Pembayaran',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...paymentMethods.map((method) => _buildPaymentMethodCard(method)),
      ],
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final bool isSelected = selectedPaymentMethod == method['id'];

    return Card(
      color: isSelected ? Colors.blue.shade50 : null,
      child: InkWell(
        onTap: () {
          setState(() {
            selectedPaymentMethod = method['id'];
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(method['icon'], color: Colors.blue),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isSelected && method['banks'] != null) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (String bank in method['banks'])
                            Chip(label: Text(bank)),
                        ],
                      ),
                    ],
                    if (isSelected && method['providers'] != null) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (String provider in method['providers'])
                            Chip(label: Text(provider)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: isLoading ? null : _processPayment,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Bayar Sekarang',
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }
}
