import 'package:flutter/material.dart';
import 'package:tiketBus/models/bus.dart';
import 'package:tiketBus/models/route.dart';
import 'package:tiketBus/models/api_response.dart';
import 'package:tiketBus/services/bus_service.dart';
import 'package:tiketBus/services/route_service.dart';
import 'package:tiketBus/services/schedule_service.dart';
import 'package:tiketBus/ticketpage.dart' as ticket;
import '../loginpage.dart';
import '../models/schedule.dart';
import '../pilihtiketpage.dart';
import '../riwayatticketpage.dart'; // Import the HistoryScreen
import '../profilepage.dart'; // Import the ProfileScreen
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/ticket_page.dart';

class HomePage1 extends StatefulWidget {
  final int initialIndex;
  const HomePage1({
    Key? key,
    this.initialIndex = 0, // Default ke tab pertama
  }) : super(key: key);

  @override
  State<HomePage1> createState() => HomePageState();
}

class HomePageState extends State<HomePage1> {
  // static int selectedIndex = 0;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _pages = [
    const HomePageContent(),
    const TicketPage(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
      body: _pages[_selectedIndex],
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
        currentIndex: _selectedIndex,
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
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _seatsController =
      TextEditingController(text: '1');
  final _formKey = GlobalKey<FormState>();

  String? selectedOrigin;
  String? selectedDestination;
  DateTime? selectedDate;
  String? selectedClass;
  Bus? selectedBus;
  bool isLoading = false;
  bool isLoadingBuses = false;
  List<Bus> buses = [];

  // Update daftar kelas bus menjadi 3 kelas
  final List<String> busClasses = ['Economy', 'Executive', 'VVIP'];

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _loadBuses();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null && mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
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

  void swapLocations() {
    setState(() {
      String tempOrigin = _originController.text;
      _originController.text = _destinationController.text;
      _destinationController.text = tempOrigin;
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

  Future<void> _onBusClassChanged(String? newValue) async {
    if (newValue != null) {
      setState(() {
        selectedClass = newValue;
        selectedBus = null;
        isLoadingBuses = true;
      });

      try {
        if (buses.isNotEmpty) {
          selectedBus = getBusFromListByClass(buses, newValue);
        }

        selectedBus ??= await getBusByClass(newValue);

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

  Future<void> _searchTickets() async {
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

      final seats = int.tryParse(_seatsController.text);
      if (seats == null || seats <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jumlah kursi tidak valid'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        if (selectedBus?.busCode == null) {
          throw Exception('Bus code tidak ditemukan');
        }

        if (selectedDate == null) {
          throw Exception('Tanggal keberangkatan belum dipilih');
        }

        print('Searching for schedules with:');
        print('Bus Code: ${selectedBus?.busCode}');
        print('Date: $selectedDate');
        print('Seats: $seats');

        final scheduleResponse = await getAvailableSchedules(
          selectedBus!.busCode!,
          selectedDate!,
        );

        if (scheduleResponse.error != null) {
          throw Exception(scheduleResponse.error);
        }

        if (scheduleResponse.data == null) {
          throw Exception('Tidak ada data jadwal');
        }

        final responseData = scheduleResponse.data;
        if (responseData is! List) {
          throw Exception('Format data tidak valid');
        }

        final List<Schedule> schedules = responseData
            .map((item) {
              if (item is! Map<String, dynamic>) {
                throw Exception('Format jadwal tidak valid');
              }
              return Schedule.fromJson(item);
            })
            .where((schedule) => schedule.availableSeats >= seats)
            .toList();

        if (schedules.isEmpty) {
          throw Exception(
              'Tidak ada jadwal tersedia dengan kursi yang mencukupi');
        }

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PilihTiketPage(
                origin: _originController.text,
                destination: _destinationController.text,
                date: selectedDate!,
                seats: seats,
                classType: selectedClass!,
                bus: selectedBus!,
                schedules: schedules,
              ),
            ),
          );
        }
      } catch (e) {
        print('Error in _searchTickets: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mencari jadwal: ${e.toString()}'),
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
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = isSmallScreen ? 6.0 : 10.0;

        return isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                              direction: isSmallScreen
                                  ? Axis.vertical
                                  : Axis.horizontal,
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 1),
                                    child: IconButton(
                                      icon: const Icon(Icons.swap_horiz,
                                          size: 20),
                                      onPressed: swapLocations,
                                      constraints:
                                          const BoxConstraints(minWidth: 24),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                if (isSmallScreen)
                                  IconButton(
                                    icon: const Icon(Icons.swap_vert, size: 20),
                                    onPressed: swapLocations,
                                    padding: EdgeInsets.zero,
                                    constraints:
                                        const BoxConstraints(minWidth: 24),
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
                                      ? DateFormat('dd/MM/yyyy')
                                          .format(selectedDate!)
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
                              direction: isSmallScreen
                                  ? Axis.vertical
                                  : Axis.horizontal,
                              children: [
                                Expanded(
                                  flex: isSmallScreen ? 0 : 1,
                                  child: TextFormField(
                                    controller: _seatsController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Jumlah Kursi',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.event_seat),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Jumlah kursi harus diisi';
                                      }
                                      final seats = int.tryParse(value);
                                      if (seats == null || seats <= 0) {
                                        return 'Jumlah kursi harus lebih dari 0';
                                      }
                                      if (seats > 4) {
                                        return 'Maksimal 4 kursi';
                                      }
                                      return null;
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
                                      prefixIcon: Icon(
                                          Icons.airline_seat_recline_normal),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 8),
                                    ),
                                    value: selectedClass,
                                    items: isLoadingBuses
                                        ? []
                                        : busClasses.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value.toLowerCase(),
                                              child: Text(value),
                                            );
                                          }).toList(),
                                    onChanged: isLoadingBuses
                                        ? null
                                        : _onBusClassChanged,
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
