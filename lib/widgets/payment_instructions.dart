import 'package:flutter/material.dart';

class PaymentInstructions extends StatelessWidget {
  const PaymentInstructions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaymentMethod(
              'Transfer Bank',
              [
                'Pilih bank tujuan transfer',
                'Salin nomor rekening yang tertera',
                'Lakukan transfer sesuai jumlah yang tertera',
                'Upload bukti transfer',
                'Tunggu konfirmasi dari admin',
              ],
            ),
            const SizedBox(height: 16),
            _buildPaymentMethod(
              'E-Wallet',
              [
                'Pilih e-wallet yang tersedia',
                'Scan QR Code yang muncul',
                'Lakukan pembayaran sesuai jumlah',
                'Pembayaran akan terkonfirmasi otomatis',
              ],
            ),
            const Divider(height: 32),
            const Text(
              'Catatan Penting:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            _buildWarningText(
              'Lakukan pembayaran dalam waktu 1x24 jam',
            ),
            _buildWarningText(
              'Booking otomatis dibatalkan jika pembayaran tidak dilakukan',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String title, List<String> steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...steps.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${entry.key + 1}. '),
                Expanded(child: Text(entry.value)),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildWarningText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
