import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'booking_confirmation.dart';
import 'models/bus.dart';
import 'models/schedule.dart';

class BookingPage extends StatefulWidget {
  final String origin;
  final String destination;
  final DateTime date;
  final int seats;
  final String classType;
  final Bus bus;
  final Schedule schedule;

  const BookingPage({
    Key? key,
    required this.origin,
    required this.destination,
    required this.date,
    required this.seats,
    required this.classType,
    required this.bus,
    required this.schedule,
  }) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  bool isLoading = false;
  Set<int> selectedSeats = {};
  List<bool> seatStatus = []; // true = available, false = booked

  @override
  void initState() {
    super.initState();
    // Tidak perlu mengurangi jumlah kursi karena sopir, kondektur, dan toilet sudah di luar grid
    seatStatus = List.generate(widget.bus.totalSeats ?? 0, (index) => true);
    // TODO: Load booked seats from API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Kursi'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bus ${widget.bus.busCode}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kelas: ${widget.bus.busClass?.toUpperCase()}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Keterangan:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildLegendItem(
                                  Colors.grey.shade300, 'Terpesan'),
                              _buildLegendItem(
                                  Colors.blue.shade100, 'Tersedia'),
                              _buildLegendItem(Colors.blue, 'Dipilih'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBusLayout(),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Kursi dipilih: ${selectedSeats.toList().join(", ")}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: selectedSeats.length == widget.seats
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingConfirmation(
                                  origin: widget.origin,
                                  destination: widget.destination,
                                  date: widget.date,
                                  seats: widget.seats,
                                  selectedSeats: selectedSeats.toList(),
                                  classType: widget.classType,
                                  bus: widget.bus,
                                  schedule: widget.schedule,
                                ),
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      'Pilih ${widget.seats} Kursi',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSeatItem({
    required int seatNumber,
    required bool isSelected,
    required bool isAvailable,
  }) {
    return GestureDetector(
      onTap: isAvailable
          ? () {
              if (selectedSeats.length < widget.seats || isSelected) {
                setState(() {
                  if (isSelected) {
                    selectedSeats.remove(seatNumber);
                  } else {
                    selectedSeats.add(seatNumber);
                  }
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Anda hanya dapat memilih ${widget.seats} kursi',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: !isAvailable
              ? Colors.grey.shade300
              : isSelected
                  ? Colors.blue
                  : Colors.blue.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            seatNumber.toString(),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBusLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - (constraints.maxWidth * 0.02 * 5)) / 4;

        return Column(
          children: [
            // Bagian depan bus (sopir & kondektur)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Kursi kondektur (sejajar dengan kursi 1,2)
                Container(
                  width: itemWidth * 2 + (constraints.maxWidth * 0.02),
                  child: Row(
                    children: [
                      Container(
                        width: itemWidth,
                        height: itemWidth,
                        margin:
                            EdgeInsets.only(right: constraints.maxWidth * 0.02),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Text(
                            'KOND',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Kursi sopir (sejajar dengan kursi 3,4)
                Container(
                  width: itemWidth * 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: itemWidth,
                        height: itemWidth,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Text(
                            'SOPIR',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Jarak setelah sopir & kondektur

            // Kursi penumpang
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                crossAxisSpacing: constraints.maxWidth * 0.02,
                mainAxisSpacing: constraints.maxWidth * 0.02,
              ),
              itemCount: widget.bus.totalSeats ?? 0,
              itemBuilder: (context, index) {
                final seatNumber = index + 1;
                final isSelected = selectedSeats.contains(seatNumber);
                final isAvailable = seatStatus[index];

                // Menambahkan jarak setelah kursi tertentu
                if (index % 4 == 1) {
                  // Setelah kursi 2, 6, 10, 14, dst
                  return Padding(
                    padding:
                        EdgeInsets.only(right: constraints.maxWidth * 0.08),
                    child: _buildSeatItem(
                      seatNumber: seatNumber,
                      isSelected: isSelected,
                      isAvailable: isAvailable,
                    ),
                  );
                }

                return _buildSeatItem(
                  seatNumber: seatNumber,
                  isSelected: isSelected,
                  isAvailable: isAvailable,
                );
              },
            ),

            // Toilet di bagian belakang
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: itemWidth,
                  height: itemWidth,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Icon(Icons.wc, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
