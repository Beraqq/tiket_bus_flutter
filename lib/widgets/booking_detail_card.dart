import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/booking.dart';

class BookingDetailCard extends StatelessWidget {
  final Booking booking;

  const BookingDetailCard({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking ID: ${booking.bookingId}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildDetailRow('Status', _getStatusText(booking.status ?? '')),
            const SizedBox(height: 8),
            _buildDetailRow('Nomor Kursi', booking.seatNumber.toString()),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Total Pembayaran',
              'Rp ${NumberFormat('#,###').format(booking.totalPrice)}',
            ),
            const Divider(height: 24),
            const Text(
              'Detail Perjalanan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Tanggal',
              booking.paymentDeadline != null
                  ? DateFormat('dd MMMM yyyy').format(booking.paymentDeadline!)
                  : 'Tidak tersedia',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
                'Rute', 'Jakarta - Bandung'), // Replace with actual data
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'paid':
        return 'Sudah Dibayar';
      case 'canceled':
        return 'Dibatalkan';
      default:
        return 'Unknown';
    }
  }
}
