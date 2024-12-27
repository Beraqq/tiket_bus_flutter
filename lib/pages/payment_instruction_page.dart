import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../models/payment.dart';

class PaymentInstructionPage extends StatelessWidget {
  final Payment payment;
  final Booking booking;

  const PaymentInstructionPage({
    Key? key,
    required this.payment,
    required this.booking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instruksi Pembayaran'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaymentInfo(),
            const SizedBox(height: 24),
            _buildPaymentInstructions(),
            if (payment.virtualAccount != null) ...[
              const SizedBox(height: 24),
              _buildVirtualAccountInfo(),
            ],
            const SizedBox(height: 24),
            _buildDeadlineInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Pembayaran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Total Pembayaran',
                'Rp ${NumberFormat('#,###').format(payment.amount)}'),
            _buildDetailRow('Metode Pembayaran',
                _getPaymentMethodName(payment.method ?? '')),
            _buildDetailRow('Status', _getStatusText(payment.status ?? '')),
          ],
        ),
      ),
    );
  }

  Widget _buildVirtualAccountInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nomor Virtual Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    payment.virtualAccount ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: payment.virtualAccount ?? ''),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInstructions() {
    final List<String> instructions = _getInstructions(payment.method ?? '');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cara Pembayaran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: instructions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${index + 1}. '),
                      Expanded(child: Text(instructions[index])),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineInfo() {
    if (payment.paymentDeadline == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Batas Waktu Pembayaran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DateFormat('dd MMMM yyyy, HH:mm')
                  .format(payment.paymentDeadline!),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Harap selesaikan pembayaran sebelum batas waktu yang ditentukan',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'bank_transfer':
        return 'Transfer Bank';
      case 'virtual_account':
        return 'Virtual Account';
      case 'e_wallet':
        return 'E-Wallet';
      default:
        return method;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'completed':
        return 'Pembayaran Berhasil';
      case 'failed':
        return 'Pembayaran Gagal';
      case 'expired':
        return 'Pembayaran Kedaluwarsa';
      default:
        return status;
    }
  }

  List<String> _getInstructions(String method) {
    switch (method) {
      case 'bank_transfer':
        return [
          'Buka aplikasi m-banking atau internet banking Anda',
          'Pilih menu Transfer',
          'Masukkan nomor rekening tujuan',
          'Masukkan jumlah transfer sesuai dengan total pembayaran',
          'Periksa kembali detail transfer',
          'Masukkan PIN atau password untuk konfirmasi',
          'Simpan bukti transfer',
          'Upload bukti transfer melalui aplikasi',
        ];
      case 'virtual_account':
        return [
          'Buka aplikasi m-banking atau internet banking Anda',
          'Pilih menu Pembayaran Virtual Account',
          'Masukkan nomor Virtual Account yang tertera',
          'Periksa detail pembayaran',
          'Konfirmasi dan selesaikan pembayaran',
          'Simpan bukti pembayaran',
        ];
      case 'e_wallet':
        return [
          'Buka aplikasi e-wallet Anda',
          'Pilih menu Scan QR atau Pay',
          'Scan kode QR yang ditampilkan',
          'Periksa detail pembayaran',
          'Konfirmasi dan selesaikan pembayaran',
          'Simpan bukti pembayaran',
        ];
      default:
        return ['Instruksi pembayaran tidak tersedia'];
    }
  }
}
