import 'package:flutter/material.dart';
import 'package:tiketBus/models/bus.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tiketBus/bookingpage.dart';

class TicketPage extends StatelessWidget {
  final String origin;
  final String destination;
  final DateTime date;
  final int seats;
  final String classType;
  final Bus bus;

  const TicketPage({
    Key? key,
    required this.origin,
    required this.destination,
    required this.date,
    required this.seats,
    required this.classType,
    required this.bus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tiket'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail Perjalanan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DetailRow(
                      icon: Icons.location_on,
                      label: 'Rute',
                      value: '$origin → $destination',
                    ),
                    const SizedBox(height: 8),
                    DetailRow(
                      icon: Icons.calendar_today,
                      label: 'Tanggal',
                      value: DateFormat('dd MMMM yyyy').format(date),
                    ),
                    const SizedBox(height: 8),
                    DetailRow(
                      icon: Icons.airline_seat_recline_normal,
                      label: 'Kelas',
                      value: classType,
                    ),
                    const SizedBox(height: 8),
                    DetailRow(
                      icon: Icons.event_seat,
                      label: 'Jumlah Kursi',
                      value: seats.toString(),
                    ),
                    const SizedBox(height: 8),
                    DetailRow(
                      icon: Icons.directions_bus,
                      label: 'Bus',
                      value: bus.busCode ?? '',
                    ),
                    const Divider(height: 32),
                    const Text(
                      'Harga',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Harga per kursi'),
                        Text(
                          'Rp ${NumberFormat('#,###').format(bus.pricePerSeat ?? 0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total ($seats kursi)'),
                        Text(
                          'Rp ${NumberFormat('#,###').format((bus.pricePerSeat ?? 0) * seats)}',
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
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingPage(
                        origin: origin,
                        destination: destination,
                        date: date,
                        seats: seats,
                        classType: classType,
                        bus: bus,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Lanjut ke Pemesanan',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget helper untuk menampilkan detail
class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const DetailRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
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
        ),
      ],
    );
  }
}
