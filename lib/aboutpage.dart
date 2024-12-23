import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

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
            children: [
              // Logo dan header
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/gambar2.png', // Pastikan path gambar sudah benar
                      width: 200,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'The Buzee.com',
                      style: TextStyle(
                        fontSize: 28, // Ukuran lebih besar untuk menonjolkan teks
                        fontWeight: FontWeight.w700, // Gaya tebal namun lebih halus
                        color: Colors.blueAccent, // Warna biru lebih cerah untuk modernitas
                        letterSpacing: 1.5, // Spasi antar huruf untuk kesan elegan
                        shadows: [
                          Shadow(
                            offset: Offset(1.5, 1.5), // Bayangan teks
                            blurRadius: 4,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Tentang perusahaan
              const Text(
                'Tentang Kami',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The Buzee.com adalah perusahaan transportasi bus yang berkomitmen memberikan layanan perjalanan antar kota dengan aman, nyaman, dan terpercaya. Kami menyediakan solusi mobilitas bagi masyarakat yang membutuhkan perjalanan efisien dengan harga terjangkau. Dengan armada modern dan tim yang profesional, kami berusaha memastikan setiap perjalanan menjadi pengalaman yang menyenangkan.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5, // Menyesuaikan jarak antar baris untuk keterbacaan
                ),
                textAlign: TextAlign.justify, // Rata kanan-kiri
              ),

              const SizedBox(height: 24),
              // Visi dan misi
              const Text(
                'Visi:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Menjadi penyedia layanan transportasi bus terbaik yang diandalkan oleh masyarakat untuk perjalanan antar kota.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5, // Menyesuaikan jarak antar baris untuk keterbacaan
                ),
                textAlign: TextAlign.justify, // Rata kanan-kiri
              ),
              const SizedBox(height: 16),
              const Text(
                'Misi:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Memberikan pelayanan berkualitas tinggi dengan mengutamakan keselamatan dan kenyamanan penumpang.\n'
                '2. Menghadirkan solusi transportasi yang efisien, ramah lingkungan, dan ekonomis.\n'
                '3. Membangun kepercayaan dan kepuasan pelanggan melalui pelayanan prima dan inovasi berkelanjutan.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5, // Menyesuaikan jarak antar baris untuk keterbacaan
                ),
                textAlign: TextAlign.justify, // Rata kanan-kiri
              ),
              const SizedBox(height: 24),
              // Layanan
              const Text(
                'Layanan Kami:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Transportasi bus antar kota dengan berbagai pilihan kelas, mulai dari ekonomi hingga premium.\n'
                '• Jadwal perjalanan yang fleksibel dan mudah diakses melalui sistem pemesanan online di website kami.\n'
                '• Fasilitas modern di setiap bus, termasuk kursi ergonomis, Wi-Fi, dan hiburan di perjalanan.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5, // Menyesuaikan jarak antar baris untuk keterbacaan
                ),
                textAlign: TextAlign.justify, // Rata kanan-kiri
              ),
              const SizedBox(height: 24),
              // Kontak
              const Text(
                'Kontak Kami:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Website: www.thebuzee.com\n'
                '• Email: info@thebuzee.com\n'
                '• Telepon: +62 800 123 4567\n'
                '• Sosial Media:\n'
                '  - Facebook: The Buzee Official\n'
                '  - Instagram: @thebuzee_id\n'
                '  - Twitter: @thebuzee',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
