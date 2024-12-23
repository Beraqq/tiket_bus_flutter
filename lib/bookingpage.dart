import 'package:flutter/material.dart';
import 'package:flutter_application_projectmp/metodebayarpage.dart';

class BookingPage extends StatefulWidget {
  final String type;
  final String code;
  final String departureLocation;
  final String arrivalLocation;
  final String departureDateTime;
  final String arrivalDateTime;

  const BookingPage({
    required this.type,
    required this.code,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.departureDateTime,
    required this.arrivalDateTime,
    super.key,
  });

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<int> selectedSeats = [];

  int rows = 0;
  int seatsPerRow = 4; // Always 4 seats per row (2-2 configuration)
  int totalSeats = 0;
  String price = '';

  @override
  void initState() {
    super.initState();

    switch (widget.type.toLowerCase()) {
      case 'ekonomi':
        totalSeats = 40;
        price = 'Rp 150.000';
        break;
      case 'executive':
        totalSeats = 30;
        price = 'Rp 250.000';
        break;
      case 'vvip':
        totalSeats = 20;
        price = 'Rp 300.000';
        break;
      default:
        totalSeats = 0;
    }
    rows = (totalSeats / seatsPerRow).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        actions: const [
          Row(
            children: [
              // Logo Image (Ensure this path matches the asset location)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Image(
                  image: AssetImage(
                      'assets/images/gambar2.png'), // Update the path to your logo image
                  height: 50, // Adjust the size of the logo
                  width: 50,
                ),
              ),
              SizedBox(width: 8),
              // The_Buzee.com Text in bold and white
              Text(
                "The_Buzee.com",
                style: TextStyle(
                  fontWeight: FontWeight.bold, // Bold text
                  fontSize: 16,
                  color: Colors.white, // White color
                ),
              ),
              SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderInfoCard(),
              const SizedBox(height: 16),
              const SectionTitle(title: 'Pilih Kursi'),
              _buildSeatSelection(),
              const SizedBox(height: 32),
              _buildContinueButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.type}\n${widget.code}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.departureLocation,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.departureDateTime,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.arrow_forward),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.arrivalLocation,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.arrivalDateTime,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeatSelection() {
    return Column(
      children: List.generate(rows, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left pair of seats
              ...List.generate(2, (seatIndex) {
                final seatNumber = (rowIndex * 4) + seatIndex + 1;
                if (seatNumber > totalSeats) return const SizedBox(width: 40);
                return SeatButton(
                  label: '$seatNumber',
                  isSelected: selectedSeats.contains(seatNumber),
                  onTap: () => _toggleSeatSelection(seatNumber),
                );
              }),

              // Aisle space
              const SizedBox(width: 40),

              // Right pair of seats
              ...List.generate(2, (seatIndex) {
                final seatNumber = (rowIndex * 4) + seatIndex + 3;
                if (seatNumber > totalSeats) return const SizedBox(width: 40);
                return SeatButton(
                  label: '$seatNumber',
                  isSelected: selectedSeats.contains(seatNumber),
                  onTap: () => _toggleSeatSelection(seatNumber),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  void _toggleSeatSelection(int seatNumber) {
    setState(() {
      if (selectedSeats.contains(seatNumber)) {
        selectedSeats.remove(seatNumber);
      } else {
        selectedSeats.add(seatNumber);
      }
    });
  }

  Widget _buildContinueButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: selectedSeats.isEmpty
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Harap pilih setidaknya satu kursi."),
                  ),
                );
              }
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentPage(
                      type: widget.type,
                      code: widget.code,
                      departureLocation: widget.departureLocation,
                      arrivalLocation: widget.arrivalLocation,
                      departureDateTime: widget.departureDateTime,
                      arrivalDateTime: widget.arrivalDateTime,
                      price: price,
                      selectedSeats: selectedSeats,
                    ),
                  ),
                );
              },
        child: const Text(
          'Lanjutkan',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class SeatButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SeatButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final seatNumber = int.parse(label);
    final isGray = seatNumber % 2 == 1; // Alternate gray seats based on number

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.red
              : isGray
                  ? Colors.blueGrey[300]
                  : Colors.white,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: Colors.grey[400]!,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
