import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tiketBus/models/bus.dart';
import 'package:tiketBus/bookingpage.dart';

// Halaman utama untuk memilih tiket
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
                    Text(
                      'Bus ${bus.busCode}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Rute: $origin - $destination',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tanggal: ${DateFormat('dd/MM/yyyy').format(date)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kelas: ${bus.busClass?.toUpperCase()}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Jumlah Kursi: $seats dari ${bus.totalSeats}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Fasilitas:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: bus.facilities
                              ?.split(', ')
                              .map((facility) => Chip(
                                    label: Text(
                                      facility,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: Colors.blue.shade50,
                                  ))
                              .toList() ??
                          [],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Harga per kursi:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Rp ${NumberFormat('#,###').format(bus.pricePerSeat ?? 0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total ($seats kursi):',
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Rp ${NumberFormat('#,###').format((bus.pricePerSeat ?? 0) * seats)}',
                          style: const TextStyle(
                            fontSize: 20,
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
