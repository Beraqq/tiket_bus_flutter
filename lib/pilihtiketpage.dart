import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/bus.dart';
import 'models/schedule.dart';
import 'bookingpage.dart';

// Halaman utama untuk memilih tiket
class PilihTiketPage extends StatefulWidget {
  final String origin;
  final String destination;
  final DateTime date;
  final int seats;
  final String classType;
  final Bus bus;
  final List<Schedule> schedules;

  const PilihTiketPage({
    super.key,
    required this.origin,
    required this.destination,
    required this.date,
    required this.seats,
    required this.classType,
    required this.bus,
    required this.schedules,
  });

  @override
  State<PilihTiketPage> createState() => _PilihTiketPageState();
}

class _PilihTiketPageState extends State<PilihTiketPage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Tersedia'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Info perjalanan
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.origin} → ${widget.destination}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tanggal: ${DateFormat('dd MMMM yyyy').format(widget.date)}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Kelas: ${widget.classType}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Jumlah Kursi: ${widget.seats}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          // Daftar jadwal
          Expanded(
            child: widget.schedules.isEmpty
                ? const Center(
                    child: Text('Tidak ada jadwal tersedia'),
                  )
                : ListView.builder(
                    itemCount: widget.schedules.length,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final schedule = widget.schedules[index];
                      final availableSeats = schedule.availableSeats ?? 0;

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        child: InkWell(
                          onTap: () {
                            if (availableSeats >= widget.seats) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingPage(
                                    origin: widget.origin,
                                    destination: widget.destination,
                                    date: widget.date,
                                    seats: widget.seats,
                                    classType: widget.classType,
                                    bus: widget.bus,
                                    schedule: schedule,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Kursi tidak mencukupi'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Jadwal ${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: availableSeats > 0
                                            ? Colors.green.shade100
                                            : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '$availableSeats Kursi',
                                        style: TextStyle(
                                          color: availableSeats > 0
                                              ? Colors.green.shade700
                                              : Colors.red.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Jam Keberangkatan',
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          schedule.departureTime ?? 'TBA',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            availableSeats >= widget.seats
                                                ? Colors.blue
                                                : Colors.grey,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                      onPressed: availableSeats >= widget.seats
                                          ? () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      BookingPage(
                                                    origin: widget.origin,
                                                    destination:
                                                        widget.destination,
                                                    date: widget.date,
                                                    seats: widget.seats,
                                                    classType: widget.classType,
                                                    bus: widget.bus,
                                                    schedule: schedule,
                                                  ),
                                                ),
                                              );
                                            }
                                          : null,
                                      child: Text(
                                        availableSeats >= widget.seats
                                            ? 'Pilih'
                                            : 'Penuh',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
