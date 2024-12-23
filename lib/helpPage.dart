import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(width: 8),
            Image.asset("assets/images/gambar2.png", height: 50),
            const Text(
              "THE_BUZEE.COM",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Ketentuan dan Layanan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '''
        • Aplikasi ini digunakan untuk pemesanan tiket bus secara online
        • Pastikan data yang dimasukkan sesuai dengan data diri penumpang
        • Pastikan pengguna memiliki jaringan internet yang stabil
        • Pembayaran dapat dilakukan melalui:
          - Transfer Bank
          - E-wallet
          - Virtual Account
        • Pembatalan tiket hanya dapat dilakukan sebelum keberangkatan
        • Pengembalian dana akan diproses dalam waktu 3-5 hari kerja
        • Pastikan untuk memeriksa kembali detail pemesanan sebelum melakukan pembayaran
        • Tiket yang sudah dibeli tidak dapat diubah atau dialihkan ke orang lain
        • Harap datang ke terminal minimal 30 menit sebelum jadwal keberangkatan
        • Tunjukkan e-ticket kepada petugas saat check-in
        • Barang bawaan tidak boleh melebihi ketentuan yang berlaku
        • Dilarang membawa barang terlarang atau berbahaya
        • Perusahaan berhak membatalkan tiket jika:
          - Data penumpang tidak sesuai
          - Melanggar ketentuan yang berlaku
          - Terlambat check-in
        • Layanan pelanggan tersedia 24 jam
        • Untuk informasi lebih lanjut dapat menghubungi call center kami
        • Syarat dan ketentuan dapat berubah sewaktu-waktu
        • Dengan menggunakan aplikasi ini, pengguna dianggap telah membaca dan menyetujui semua ketentuan yang berlaku
        • Perusahaan tidak bertanggung jawab atas:
          - Keterlambatan karena force majeure
          - Kehilangan barang pribadi
          - Kecelakaan yang disebabkan kelalaian penumpang
        • Penumpang wajib mematuhi protokol kesehatan yang berlaku
        • Anak-anak di bawah 17 tahun wajib didampingi orang tua
        • Penumpang berkebutuhan khusus harap memberitahu sebelumnya
        • Hewan peliharaan tidak diperbolehkan
        • Merokok dilarang di dalam bus
        • Mohon jaga kebersihan dan ketertiban selama perjalanan
        ''',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5, // Memberikan jarak antar baris agar lebih rapi
                  ),
                  textAlign: TextAlign.justify, // Rata kanan-kiri
                ),
              ],
            ),
          ),
        ),
    );
  }
}

// Usage example
void main() {
  runApp(
    const MaterialApp(
      home: HelpPage(),
    ),
  );
}