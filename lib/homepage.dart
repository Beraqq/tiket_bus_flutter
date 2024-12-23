import 'package:flutter/material.dart';
import 'package:flutter_application_projectmp/pilihtiketpage.dart';
import 'ticketpage.dart'; // Import the TicketPage
import 'riwayatticketpage.dart'; // Import the HistoryScreen
import 'profilepage.dart'; // Import the ProfileScreen

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0; // Set the initial index to 0 for the HomePage

  // Pages for the BottomNavigationBar
  final List<Widget> _pages = [
    const HomePageContent(), // HomePage widget
    const EBoardingPassScreen(), // TicketPage widget
    const HistoryScreen(), // HistoryPage widget
    const ProfileScreen(), // ProfilePage widget
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

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
      body: _pages[selectedIndex], // Show the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number), label: 'Ticket'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  String? selectedOrigin;
  String? selectedDestination;
  DateTime? selectedDate;
  int selectedSeats = 1; // Default number of seats
  String? selectedClass; // New variable for class selection

  final List<String> origins = [
    'Tangerang',
    'Jakarta',
    'Bandung',
    'Surabaya',
  ];

  final List<String> destinations = [
    'Purworejo',
    'Yogyakarta',
    'Semarang',
    'Bali',
  ];

  final List<String> classes = [
    'Ekonomi',
    'Executive',
    'VVIP',
  ];

  int getAvailableSeats() {
    switch (selectedClass) {
      case 'Ekonomi':
        return 40;
      case 'Executive':
        return 30;
      case 'VVIP':
        return 20;
      default:
        return 0; // No seats available if no class is selected
    }
  }

  

  void swapLocations() {
    setState(() {
      final temp = selectedOrigin;
      selectedOrigin = selectedDestination;
      selectedDestination = temp;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 25.0),
              child: Image.asset(
                "assets/images/gambar1.png",
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
           Container(           
              margin: const EdgeInsets.only(bottom: 10.0), // Menambahkan margin di bawah
              child: const Text(
                "Pilih Keberangkatan",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showMenu<String>(
                        context: context,
                        position: const RelativeRect.fromLTRB(40, 340, 110, 100),
                        items: origins.map((String origin) {
                          return PopupMenuItem<String>(
                            value: origin,
                            child: Text(origin),
                          );
                        }).toList(),
                      ).then((String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedOrigin = newValue;
                          });
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 7.0), // Ubah nilai ini sesuai kebutuhan
                                  child: Image.asset(
                                    "assets/images/icon_lokasi.png",
                                    height: 24,
                                    width: 24,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Text(selectedOrigin ?? "Pilih Asal"),
                            ],
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: swapLocations,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showMenu<String>(
                        context: context,
                        position: const RelativeRect.fromLTRB(230, 340, 250, 0),
                        items: destinations.map((String destination) {
                          return PopupMenuItem<String>(
                            value: destination,
                            child: Text(destination),
                          );
                        }).toList(),
                      ).then((String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedDestination = newValue;
                          });
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                             Padding(
                                padding: const EdgeInsets.only(left: 7.0), // Ubah nilai ini sesuai kebutuhan
                                child: Image.asset(
                                  "assets/images/icon_tujuan.png",
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(selectedDestination ?? "Pilih Tujuan"),
                            ],
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Container(
                margin: const EdgeInsets.only(bottom: 10.0), // Menambahkan margin di bawah
                child: const Text(
                  "Tanggal Keberangkatan",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0), // Jarak di sebelah kiri teks
                          child: Text(
                            selectedDate == null
                                ? "Pilih Tanggal"
                                : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0), // Jarak di sebelah kanan ikon
                          child: const Icon(Icons.calendar_today),
                        ),
                      ],
                    ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
             Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Fixed height for the text to keep it in place
                          Container(
                            height: 40, // Set a fixed height for the text
                            padding: const EdgeInsets.only(left: 6.0, bottom: 10.0), // Padding for the text
                            child: const Text(
                              "Jumlah Kursi",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          // Row containing the image and dropdown
                         Row(
                           children: [
                               Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 0), // Padding for the image
                          child: Transform.translate(
                            offset: const Offset(5, -8), // Move the image up by 4 pixels
                            child: Image.asset(
                              "assets/images/icon_kursibus.png",
                              height: 25,
                             width: 25,
                            ),
                          ),
                        ),
                         const SizedBox(width: 17), // Space between image and dropdown
                        Container(
                          height: 40,
                          width: 50, // Atur lebar sesuai kebutuhan

                            child: DropdownButton<int>(
                              value: selectedSeats,
                              hint: const Text(
                                "00",
                                style: TextStyle(fontSize: 12),
                              ),
                              items: List.generate(getAvailableSeats(), (index) => index + 1)
                                  .map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                                    child: Text(value.toString()),
                                  ),
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                setState(() {
                                  selectedSeats = newValue!;
                                });
                              },
                              isExpanded: true, // Memastikan dropdown mengisi ruang yang tersedia
                            ),     
                        ),
                      ],
                    ),
                  ],
                 ),
              ),
                  const SizedBox(width: 0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     Padding(
                          padding: const EdgeInsets.only(left: 6.0,bottom: 10.0), // Jarak di bawah teks
                          child: const Text(
                            "Kelas Armada",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                  children: [
                    Padding(
                     padding: const EdgeInsets.only(left: 0.0), // Menambahkan padding kiri untuk ikon
                     child: Image.asset(
                       "assets/images/icon_classbus.png",
                       height: 50,
                       width: 50,
                     ),
                   ),
                   const SizedBox(width: 0),
                   Expanded(
                     child: DropdownButton<String>(
                       isExpanded: true,
                       value: selectedClass,
                       hint: const Text(
                         "Pilih Kelas",
                         style: TextStyle(fontSize: 12),
                       ),
                       items: classes.map((String className) {
                         return DropdownMenuItem<String>(
                           value: className,
                          child: Padding(
                       padding: const EdgeInsets.symmetric(vertical: 8.0), // Menambahkan padding vertikal
                       child: Text(className),
                          ),
                         );
                       }).toList(),
                       onChanged: (String? newValue) {
                         setState(() {
                           selectedClass = newValue;
                           selectedSeats = 1; // Reset selected seats when class changes
                         });
                       },
                     ),
                   ),
                 ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32.0),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Ubah nilai sesuai kebutuhan
      ),
                  ),
                  onPressed: () {
                    if (selectedOrigin != null &&
                        selectedDestination != null &&
                        selectedDate != null &&
                        selectedClass != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TicketPage(
                            origin: selectedOrigin!,
                            destination: selectedDestination!,
                            date: selectedDate!,
                            seats: selectedSeats,
                            classType: selectedClass!,
                          ),
                        ),
                      );
                    } else {
                      // Show error message if data is incomplete
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Silakan lengkapi semua pilihan.")),
                      );
                    }
                  },
                  child: const Text("Cari Tiket",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
