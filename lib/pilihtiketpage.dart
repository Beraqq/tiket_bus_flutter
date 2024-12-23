import 'package:flutter/material.dart';
import 'package:flutter_application_projectmp/detailkelasarmada.dart';

// Halaman utama untuk memilih tiket
class TicketPage extends StatelessWidget {
  final String origin;
  final String destination;
  final DateTime date;
  final int seats;
  final String classType;

  const TicketPage({super.key, 
    required this.origin,
    required this.destination,
    required this.date,
    required this.seats,
    required this.classType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 8),
          ],
        ),
        actions: [
          Row(
            children: [
              const SizedBox(width: 8),
              Image.asset(
                'assets/images/gambar2.png', // Pastikan gambar ada di folder assets
                height: 35,
              ),
              const SizedBox(width: 4),
              const Text(
                "The_Buzee.com",
                style: TextStyle(
                  fontWeight: FontWeight.bold, // Bold text
                  fontSize: 16,
                  color: Colors.white, // White color
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.blue,
        foregroundColor: Colors.black,
        elevation: 2,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blueGrey[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        origin,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        destination,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      "${date.day} ${_getMonthName(date.month)} ${date.year}",
                      style: const TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "$seats Kursi",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      "Kelas Armada:",
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      classType,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: _getTicketCards(context, classType),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    return monthNames[month - 1];
  }

  List<Widget> _getTicketCards(BuildContext context, String classType) {
    List<Widget> tickets = [];

    if (classType == "Ekonomi") {
      tickets.add(ticketCard(context, "Ekonomi", "TBC-001", "07:30", "18:30",
          150000, origin, destination, "11 jam"));
      tickets.add(ticketCard(context, "Ekonomi", "TBC-002", "12:00", "23:00",
          150000, origin, destination, "11 jam"));
    } else if (classType == "Executive") {
      tickets.add(ticketCard(context, "Executive", "TBC-007", "06:00", "17:00",
          250000, origin, destination, "11 jam"));
      tickets.add(ticketCard(context, "Executive", "TBC-008", "11:00", "22:00",
          250000, origin, destination, "11 jam"));
    } else if (classType == "VVIP") {
      tickets.add(ticketCard(context, "VVIP", "TBC-013", "05:00", "16:00",
          300000, origin, destination, "11 jam"));
      tickets.add(ticketCard(context, "VVIP", "TBC-014", "10:00", "21:00",
          300000, origin, destination, "11 jam"));
    } else {
      tickets.add(const Center(child: Text("Tidak ada tiket tersedia.")));
    }

    return tickets;
  }

  Widget ticketCard(
      BuildContext context,
      String type,
      String code,
      String departureTime,
      String arrivalTime,
      int price,
      String origin,
      String destination,
      String travelTime) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Kode: $code",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87)),
                Text("IDR $price / Kursi",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.circle, color: Colors.blue, size: 16),
              const SizedBox(width: 8),
              Text("$origin - $departureTime")
            ]),
            Row(children: [
              const Icon(Icons.circle, color: Colors.red, size: 16),
              const SizedBox(width: 8),
              Text("$destination - $arrivalTime")
            ]),
            const SizedBox(height: 12),
            Text("Waktu Perjalanan: $travelTime",
                style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArmadaDetailPage(
                        type: type,
                        code: code,
                        pricePerSeat: price.toDouble(),
                        departureLocation: origin,
                        arrivalLocation: destination,
                        departureDateTime: departureTime,
                        arrivalDateTime: arrivalTime,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text("Detail"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
