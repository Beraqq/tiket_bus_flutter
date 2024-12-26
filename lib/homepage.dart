import 'package:flutter/material.dart';
import 'package:tiketBus/models/bus.dart';
import 'package:tiketBus/models/route.dart';
import 'package:tiketBus/models/api_response.dart';
import 'package:tiketBus/services/bus_service.dart';
import 'package:tiketBus/services/route_service.dart';
import 'package:tiketBus/services/schedule_service.dart';
import 'package:tiketBus/ticketpage.dart' as ticket;
import 'loginpage.dart';
import 'pilihtiketpage.dart';
import 'riwayatticketpage.dart'; // Import the HistoryScreen
import 'profilepage.dart'; // Import the ProfileScreen
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePageContent(), // index 0 - Home
    const HistoryScreen(), // index 1 - Tiket
    const HistoryScreen(), // index 2 - Riwayat
    const ProfileScreen(), // index 3 - Profile
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
      body: _pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Tiket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
        backgroundColor: Colors.blue,
        type: BottomNavigationBarType.fixed,
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
  int selectedSeats = 1;
  String? selectedClass;
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  List<Bus> buses = [];
  Bus? selectedBus;
  bool isLoadingBuses = false;
  final _formKey = GlobalKey<FormState>();
  final List<String> busClasses = ['economy', 'executive', 'VVIP'];

  @override
  void initState() {
    super.initState();
    _loadBuses();
  }

  Future<void> _loadBuses() async {
    setState(() {
      isLoadingBuses = true;
    });

    ApiResponse response = await getBuses();

    if (mounted) {
      setState(() {
        isLoadingBuses = false;
      });

      if (response.error == 'Session expired. Please login again') {
        // Redirect ke halaman login
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi Anda telah berakhir. Silakan login kembali.'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (response.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error!),
            backgroundColor: Colors.red,
          ),
        );
      } else if (response.data != null) {
        setState(() {
          buses = response.data as List<Bus>;
        });
      }
    }
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void swapLocations() {
    setState(() {
      String? tempOrigin = _originController.text;
      _originController.text = _destinationController.text;
      _destinationController.text = tempOrigin;
      selectedOrigin = _destinationController.text;
      selectedDestination = _originController.text;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _saveDepartureDate(DateTime date) async {
    if (_originController.text.isNotEmpty &&
        _destinationController.text.isNotEmpty) {
      // Simpan route terlebih dahulu
      ApiResponse routeResponse = await createRoute(
          _originController.text, _destinationController.text);

      if (routeResponse.error == null && routeResponse.data != null) {
        Map<String, dynamic> routeData =
            routeResponse.data as Map<String, dynamic>;
        BusRoute route = BusRoute.fromJson(routeData);

        if (route.routeId != null && selectedBus != null) {
          // Tambahkan pengecekan selectedBus
          ApiResponse scheduleResponse = await createSchedule(
              route.routeId!,
              date,
              selectedBus!.busCode!, // Tambahkan bus_code
              selectedSeats // Tambahkan selected_seats
              );

          if (scheduleResponse.error == null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Jadwal berhasil disimpan')),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${scheduleResponse.error}')),
              );
            }
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('${routeResponse.error ?? "Gagal membuat rute"}')),
          );
        }
      }
    }
  }

  void _saveRoute() async {
    if (_originController.text.isNotEmpty &&
        _destinationController.text.isNotEmpty) {
      ApiResponse response = await createRoute(
          _originController.text, _destinationController.text);

      if (response.error == null) {
        // Rute berhasil disimpan
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rute berhasil disimpan')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${response.error}')),
          );
        }
      }
    }
  }

  // Fungsi untuk menyimpan rute dan jadwal
  Future<bool> _saveRouteAndSchedule() async {
    if (_originController.text.isEmpty ||
        _destinationController.text.isEmpty ||
        selectedDate == null ||
        selectedBus == null) {
      // Tambahkan pengecekan selectedBus
      return false;
    }

    // Simpan route terlebih dahulu
    ApiResponse routeResponse =
        await createRoute(_originController.text, _destinationController.text);

    if (routeResponse.error == null && routeResponse.data != null) {
      Map<String, dynamic> routeData =
          routeResponse.data as Map<String, dynamic>;
      BusRoute route = BusRoute.fromJson(routeData);

      if (route.routeId != null) {
        // Simpan schedule dengan semua parameter yang dibutuhkan
        ApiResponse scheduleResponse = await createSchedule(
            route.routeId!,
            selectedDate!,
            selectedBus!.busCode!, // Tambahkan bus_code
            selectedSeats // Tambahkan selected_seats
            );

        if (scheduleResponse.error == null) {
          return true;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${scheduleResponse.error}')),
            );
          }
          return false;
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${routeResponse.error ?? "Gagal membuat rute"}')),
        );
      }
      return false;
    }
    return false;
  }

  void _searchTickets() async {
    if (_formKey.currentState!.validate()) {
      if (selectedClass == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih kelas armada terlebih dahulu'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Pastikan selectedBus sudah ada
      if (selectedBus == null) {
        // Coba ambil bus berdasarkan kelas yang dipilih
        selectedBus = await getBusByClass(selectedClass!);
      }

      if (selectedBus == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data bus tidak ditemukan'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Navigate ke TicketPage dengan parameter yang lengkap
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TicketPage(
            origin: _originController.text,
            destination: _destinationController.text,
            date: selectedDate!,
            seats: selectedSeats,
            classType: selectedClass!,
            bus: selectedBus!,
          ),
        ),
      );
    }
  }

  void _onBusClassChanged(String? newValue) async {
    if (newValue != null) {
      setState(() {
        selectedClass = newValue;
        selectedBus = null;
        isLoadingBuses = true;
      });

      try {
        // Coba cari dari list buses yang sudah ada
        if (buses.isNotEmpty) {
          selectedBus = getBusFromListByClass(buses, newValue);
        }

        // Jika tidak ditemukan, coba ambil dari API
        if (selectedBus == null) {
          selectedBus = await getBusByClass(newValue);
        }

        if (mounted) {
          setState(() {
            isLoadingBuses = false;
          });

          if (selectedBus == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Tidak dapat menemukan bus kelas ${newValue.toUpperCase()}'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            print(
                'Selected bus: ${selectedBus?.busCode} - ${selectedBus?.busClass}');
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isLoadingBuses = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengambil data bus: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = isSmallScreen ? 6.0 : 10.0;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: isSmallScreen ? 6.0 : 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Image.asset(
                      "assets/images/gambar1.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 6.0),
                        child: Text(
                          "Pilih Keberangkatan",
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Flex(
                        direction:
                            isSmallScreen ? Axis.vertical : Axis.horizontal,
                        children: [
                          Expanded(
                            flex: isSmallScreen ? 0 : 10,
                            child: TextFormField(
                              controller: _originController,
                              decoration: const InputDecoration(
                                labelText: 'Kota Asal',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 4),
                                isDense: true,
                              ),
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Pilih kota asal'
                                  : null,
                            ),
                          ),
                          if (!isSmallScreen)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 1),
                              child: IconButton(
                                icon: const Icon(Icons.swap_horiz, size: 20),
                                onPressed: swapLocations,
                                constraints: const BoxConstraints(minWidth: 24),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          if (isSmallScreen)
                            IconButton(
                              icon: const Icon(Icons.swap_vert, size: 20),
                              onPressed: swapLocations,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 24),
                            ),
                          Expanded(
                            flex: isSmallScreen ? 0 : 10,
                            child: TextFormField(
                              controller: _destinationController,
                              decoration: const InputDecoration(
                                labelText: 'Kota Tujuan',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 4),
                                isDense: true,
                              ),
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Pilih kota tujuan'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        margin: const EdgeInsets.only(bottom: 6.0),
                        child: Text(
                          "Tanggal Keberangkatan",
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            selectedDate != null
                                ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                                : 'Pilih Tanggal',
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 24),
                      Container(
                        margin: const EdgeInsets.only(bottom: 6.0),
                        child: Text(
                          "Detail Perjalanan",
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Flex(
                        direction:
                            isSmallScreen ? Axis.vertical : Axis.horizontal,
                        children: [
                          Expanded(
                            flex: isSmallScreen ? 0 : 1,
                            child: DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: 'Jumlah Kursi',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.event_seat),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                              ),
                              value: selectedSeats,
                              items: List.generate(10, (index) => index + 1)
                                  .map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(value.toString()),
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                setState(() {
                                  selectedSeats = newValue ?? 1;
                                });
                              },
                            ),
                          ),
                          SizedBox(
                              width: isSmallScreen ? 0 : 8,
                              height: isSmallScreen ? 16 : 0),
                          Expanded(
                            flex: isSmallScreen ? 0 : 1,
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Kelas Armada',
                                border: OutlineInputBorder(),
                                prefixIcon:
                                    Icon(Icons.airline_seat_recline_normal),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                              ),
                              value: selectedClass,
                              items: isLoadingBuses
                                  ? []
                                  : busClasses.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value.toUpperCase()),
                                      );
                                    }).toList(),
                              onChanged:
                                  isLoadingBuses ? null : _onBusClassChanged,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Pilih kelas armada';
                                }
                                return null;
                              },
                              hint: isLoadingBuses
                                  ? const Text('Loading...')
                                  : const Text('Pilih Kelas'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 12 : 16,
                            ),
                          ),
                          onPressed: _searchTickets,
                          child: Text(
                            'Cari Tiket',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
