import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/bus.dart';
import 'models/schedule.dart';
import 'models/booking.dart';
import 'models/api_response.dart';
import 'services/booking_service.dart';
import 'payment_page.dart';

class BookingConfirmation extends StatefulWidget {
  final String origin;
  final String destination;
  final DateTime date;
  final int seats;
  final List<int> selectedSeats;
  final String classType;
  final Bus bus;
  final Schedule schedule;

  const BookingConfirmation({
    Key? key,
    required this.origin,
    required this.destination,
    required this.date,
    required this.seats,
    required this.selectedSeats,
    required this.classType,
    required this.bus,
    required this.schedule,
  }) : super(key: key);

  @override
  State<BookingConfirmation> createState() => _BookingConfirmationState();
}

class _BookingConfirmationState extends State<BookingConfirmation> {
  bool isLoading = false;
  final BookingService _bookingService = BookingService();

  @override
  void initState() {
    super.initState();
    print('Schedule data:');
    print('Schedule ID: ${widget.schedule.scheduleId}');
    print('Bus Code: ${widget.schedule.busCode}');
    print('Route ID: ${widget.schedule.routeId}');
  }

  void _createBooking() async {
    setState(() {
      isLoading = true;
    });

    try {
      final totalPrice = (widget.bus.pricePerSeat ?? 0) * widget.seats;
      ApiResponse? lastResponse;

      print('Attempting to create booking with:');
      print('Schedule ID: ${widget.schedule.scheduleId}');
      print('Total Price: $totalPrice');
      print('Selected Seats: ${widget.selectedSeats}');

      if (widget.schedule.scheduleId == null ||
          widget.schedule.scheduleId!.isEmpty) {
        throw Exception('Schedule ID tidak valid');
      }

      for (int seatNumber in widget.selectedSeats) {
        print('Creating booking for seat: $seatNumber');

        final response = await _bookingService.createBooking(
          scheduleId: widget.schedule.scheduleId!,
          seatNumber: seatNumber,
          totalPrice: totalPrice / widget.seats,
        );

        if (response.error != null) {
          throw Exception(response.error);
        }

        lastResponse = response;
        print('Booking created successfully for seat: $seatNumber');
      }

      if (mounted && lastResponse?.data != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentPage(
              booking: lastResponse!.data as Booking,
            ),
          ),
        );
      } else {
        throw Exception('No booking data received');
      }
    } catch (e) {
      print('Error creating booking: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat pemesanan: ${e.toString()}'),
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
        title: const Text('Konfirmasi Pemesanan'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                            'Detail Pemesanan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow('Rute',
                              '${widget.origin} → ${widget.destination}'),
                          _buildDetailRow('Tanggal',
                              DateFormat('dd MMMM yyyy').format(widget.date)),
                          _buildDetailRow('Bus', widget.bus.busCode ?? ''),
                          _buildDetailRow('Kelas', widget.classType),
                          _buildDetailRow(
                              'Kursi', widget.selectedSeats.join(', ')),
                          const Divider(height: 32),
                          _buildDetailRow(
                            'Total Pembayaran',
                            'Rp ${NumberFormat('#,###').format((widget.bus.pricePerSeat ?? 0) * widget.seats)}',
                            isTotal: true,
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
                      onPressed: _createBooking,
                      child: const Text(
                        'Konfirmasi Pemesanan',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
