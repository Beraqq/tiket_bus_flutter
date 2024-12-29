import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tiketBus/constant.dart';
import 'package:tiketBus/services/user_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> bookingHistory = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchBookingHistory();
  }

  Future<void> _fetchBookingHistory() async {
    try {
      final token = await getToken();
      print('Token for history request: $token');

      final response = await http.get(
        Uri.parse('$baseURL/bookings'),
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );

      print('History Response Status: ${response.statusCode}');
      print('History Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            bookingHistory = List<Map<String, dynamic>>.from(
                data['bookings'] ?? data['data'] ?? []);
            print('Booking History Data:');
            print(bookingHistory);
            isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Gagal mengambil data');
        }
      } else if (response.statusCode == 404) {
        setState(() {
          bookingHistory = [];
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else {
        throw Exception(
            'Gagal mengambil riwayat pemesanan (${response.statusCode})');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        error = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'HISTORY PEMESANAN',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(error!));
    }

    if (bookingHistory.isEmpty) {
      return const Center(child: Text('Belum ada riwayat pemesanan'));
    }

    return RefreshIndicator(
      onRefresh: _fetchBookingHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookingHistory.length,
        itemBuilder: (context, index) {
          final booking = bookingHistory[index];
          final schedule = booking['schedule'];

          // Format tanggal dari created_at
          final DateTime bookingDate = DateTime.parse(booking['created_at']);
          final String formattedDate =
              "${bookingDate.day}/${bookingDate.month}/${bookingDate.year}";

          return Column(
            children: [
              _buildTicketCard(
                booking: booking,
                date: formattedDate,
                departureTime: schedule != null
                    ? schedule['departure_time'] ?? 'TBA'
                    : 'TBA',
                departureCity: schedule != null
                    ? schedule['departure_city'] ?? 'TBA'
                    : 'TBA',
                arrivalTime: schedule != null
                    ? schedule['arrival_time'] ?? 'TBA'
                    : 'TBA',
                arrivalCity: schedule != null
                    ? schedule['arrival_city'] ?? 'TBA'
                    : 'TBA',
                price: 'Rp ${booking['total_price']}',
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTicketCard({
    required Map<String, dynamic> booking,
    required String date,
    required String departureTime,
    required String departureCity,
    required String arrivalTime,
    required String arrivalCity,
    required String price,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Booking Code: ${booking['booking_code']}',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTimelineSection(
                  time: departureTime,
                  city: departureCity,
                  isStart: true,
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Seat: ${booking['seat_number']}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _buildTimelineSection(
              time: arrivalTime,
              city: arrivalCity,
              isStart: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    // Tambahkan fungsi untuk melihat detail tiket
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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

  Widget _buildTimelineSection({
    required String time,
    required String city,
    required bool isStart,
  }) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue,
                  width: 2,
                ),
                color: Colors.white,
              ),
            ),
            if (!isStart)
              Container(
                width: 2,
                height: 30,
                color: Colors.blue,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '$city Bus Station',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
