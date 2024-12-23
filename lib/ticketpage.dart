import 'package:flutter/material.dart';

class EBoardingPassScreen extends StatelessWidget {
  const EBoardingPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data tiket
    final Map<String, dynamic> ticketData = {
      "nama": "Ridwan Setiawan",
      "tanggal": "Selasa, 03 Desember 2024",
      "asal": "Jakarta",
      "tujuan": "Bandung",
      "noTiket": "K890T",
      "noKursi": "31, 32",
      "kelas": "Executive",
      "kodeBus": "BZ.080",
      "fasilitas": "Makan 1X",
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Boarding Pass'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // Added scrollable widget
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/gambar2.png",
                    height: 100,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'E-Boarding Pass',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Nama', ticketData['nama']),
                  _buildDetailRow('Berangkat', ticketData['tanggal']),
                  _buildDetailRow('Asal', ticketData['asal']),
                  _buildDetailRow('Tujuan', ticketData['tujuan']),
                  _buildDetailRow('No. Tiket', ticketData['noTiket']),
                  _buildDetailRow('No. Kursi', ticketData['noKursi']),
                  _buildDetailRow('Kelas', ticketData['kelas']),
                  _buildDetailRow('Kode Bus', ticketData['kodeBus']),
                  const SizedBox(height: 16),
                  const Text('QR Code'),
                  const SizedBox(height: 16),
                  Image.network(
                    'https://tse1.mm.bing.net/th?id=OIP.QwBBzcRPt-Kpu26kJT_vKgHaHa&pid=Api&P=0&h=180', // Placeholder QR code
                    height: 100,
                  ),
                  const SizedBox(height: 16),
                  Text('Fasilitas: ${ticketData['fasilitas']}'),
                  const Divider(height: 20, color: Colors.grey),
                  const Text(
                    'Apabila memerlukan bantuan, silakan hubungi Call Center:\nTelp: 0217-30000059, WA: 083645712432\nEmail: csbuzee@gmail.com',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showTicketDetails(context, ticketData);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _showTicketDetails(
      BuildContext context, Map<String, dynamic> ticketData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detail Tiket'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama: ${ticketData['nama']}'),
              Text('Tanggal Berangkat: ${ticketData['tanggal']}'),
              Text('Asal: ${ticketData['asal']}'),
              Text('Tujuan: ${ticketData['tujuan']}'),
              Text('Kelas: ${ticketData['kelas']}'),
              Text('Kode Bus: ${ticketData['kodeBus']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
