import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../models/api_response.dart';
import '../loginpage.dart';
import 'dart:async';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketPage extends StatefulWidget {
  const TicketPage({Key? key}) : super(key: key);

  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  final BookingService _bookingService = BookingService();
  bool isLoading = true;
  List<Booking> tickets = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadTickets();
    // Refresh lebih sering untuk tiket yang baru dibayar
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _loadTickets();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      print('Fetching tickets...');
      ApiResponse response = await _bookingService.getActiveBookings();
      print('Response received: ${response.error ?? 'Success'}');

      if (!mounted) return;

      if (response.error == null) {
        setState(() {
          if (response.data is List) {
            tickets = (response.data as List).cast<Booking>();
            print('Loaded ${tickets.length} tickets');

            // Debug: print seat numbers for each ticket
            for (var ticket in tickets) {
              print('Ticket ${ticket.bookingCode}:');
              print('Seat Numbers: ${ticket.seatNumbers}');
            }
          } else {
            tickets = [];
          }
          isLoading = false;
        });
      } else {
        setState(() {
          tickets = [];
          isLoading = false;
        });

        if (response.error!.toLowerCase().contains('unauthorized')) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading tickets: $e');
      if (!mounted) return;

      setState(() {
        tickets = [];
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat tiket: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _checkPendingPayments() async {
    print('Checking pending payments...');
    for (var ticket in tickets) {
      // Cek semua tiket yang pending atau baru dibayar
      if (ticket.paymentStatus?.toLowerCase() == 'pending' ||
          ticket.paymentStatus?.toLowerCase() == 'processing') {
        print('Checking payment status for ticket: ${ticket.bookingCode}');

        final response =
            await _bookingService.checkPaymentStatus(ticket.id ?? '');

        if (response.error == null && response.data != null) {
          print(
              'Payment status received for ${ticket.bookingCode}: ${response.data}');

          // Jika status berbeda, reload tiket
          if (response.data != ticket.paymentStatus) {
            print(
                'Status changed from ${ticket.paymentStatus} to ${response.data}');
            await _loadTickets(); // Reload semua tiket
            break;
          }
        } else {
          print('Error checking payment status: ${response.error}');
        }
      }
    }
  }

  Future<void> _generateTicketPDF(Booking ticket) async {
    try {
      final pdf = pw.Document();

      // Load font
      final font = await PdfGoogleFonts.nunitoRegular();
      final boldFont = await PdfGoogleFonts.nunitoBold();

      // Get user data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('name') ?? 'N/A';
      final userEmail = prefs.getString('email') ?? 'N/A';
      final userPhone = prefs.getString('phone') ?? 'N/A';

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'E-Ticket Bus',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 24,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Tiket Bus Online',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 14,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Booking Code
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(5)),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Kode Booking:',
                          style: pw.TextStyle(font: boldFont),
                        ),
                        pw.Text(
                          ticket.bookingCode ?? 'N/A',
                          style: pw.TextStyle(font: boldFont),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Passenger Info
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(5)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Data Penumpang',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 16,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('Nama:',
                                      style: pw.TextStyle(font: font)),
                                  pw.Text(userName,
                                      style: pw.TextStyle(font: boldFont)),
                                  pw.SizedBox(height: 5),
                                  pw.Text('Email:',
                                      style: pw.TextStyle(font: font)),
                                  pw.Text(userEmail,
                                      style: pw.TextStyle(font: boldFont)),
                                ],
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('Telepon:',
                                      style: pw.TextStyle(font: font)),
                                  pw.Text(userPhone,
                                      style: pw.TextStyle(font: boldFont)),
                                  pw.SizedBox(height: 5),
                                  pw.Text('Tanggal Booking:',
                                      style: pw.TextStyle(font: font)),
                                  pw.Text(_formatDate(DateTime.now()),
                                      style: pw.TextStyle(font: boldFont)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Schedule, Route, dan Bus Info
                  if (ticket.schedule != null) ...[
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(5)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Detail Perjalanan',
                            style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 16,
                            ),
                          ),
                          pw.SizedBox(height: 10),

                          // Route Info
                          pw.Row(
                            children: [
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text('Dari:',
                                        style: pw.TextStyle(font: font)),
                                    pw.Text(ticket.schedule!.origin ?? 'N/A',
                                        style: pw.TextStyle(font: boldFont)),
                                    pw.SizedBox(height: 5),
                                    pw.Text('Terminal:',
                                        style: pw.TextStyle(font: font)),
                                    pw.Text(
                                        ticket.schedule!.originDetail ?? 'N/A',
                                        style: pw.TextStyle(font: boldFont)),
                                  ],
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text('Ke:',
                                        style: pw.TextStyle(font: font)),
                                    pw.Text(
                                        ticket.schedule!.destination ?? 'N/A',
                                        style: pw.TextStyle(font: boldFont)),
                                    pw.SizedBox(height: 5),
                                    pw.Text('Terminal:',
                                        style: pw.TextStyle(font: font)),
                                    pw.Text(
                                        ticket.schedule!.destinationDetail ??
                                            'N/A',
                                        style: pw.TextStyle(font: boldFont)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 10),
                          pw.Divider(color: PdfColors.grey300),
                          pw.SizedBox(height: 10),

                          // Schedule Info
                          pw.Row(
                            children: [
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text('Tanggal Keberangkatan:',
                                        style: pw.TextStyle(font: font)),
                                    pw.Text(
                                        _formatDate(
                                            ticket.schedule!.departureDateTime),
                                        style: pw.TextStyle(font: boldFont)),
                                    pw.SizedBox(height: 5),
                                    pw.Text('Jam Keberangkatan:',
                                        style: pw.TextStyle(font: font)),
                                    pw.Text(
                                        _formatTime(
                                            ticket.schedule!.departureDateTime),
                                        style: pw.TextStyle(font: boldFont)),
                                  ],
                                ),
                              ),
                              if (ticket.schedule!.arrivalDateTime != null)
                                pw.Expanded(
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text('Tanggal Kedatangan:',
                                          style: pw.TextStyle(font: font)),
                                      pw.Text(
                                          _formatDate(ticket
                                              .schedule!.arrivalDateTime!),
                                          style: pw.TextStyle(font: boldFont)),
                                      pw.SizedBox(height: 5),
                                      pw.Text('Jam Kedatangan:',
                                          style: pw.TextStyle(font: font)),
                                      pw.Text(
                                          _formatTime(ticket
                                              .schedule!.arrivalDateTime!),
                                          style: pw.TextStyle(font: boldFont)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          pw.SizedBox(height: 10),
                          pw.Divider(color: PdfColors.grey300),
                          pw.SizedBox(height: 10),

                          // Bus Info
                          if (ticket.schedule!.bus != null) ...[
                            pw.Text(
                              'Informasi Bus',
                              style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 14,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Row(
                              children: [
                                pw.Expanded(
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text('Kode Bus:',
                                          style: pw.TextStyle(font: font)),
                                      pw.Text(
                                          ticket.schedule!.bus!.busCode ??
                                              'N/A',
                                          style: pw.TextStyle(font: boldFont)),
                                    ],
                                  ),
                                ),
                                pw.Expanded(
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text('Kelas:',
                                          style: pw.TextStyle(font: font)),
                                      pw.Text(
                                          ticket.schedule!.bus!.busClass ??
                                              'N/A',
                                          style: pw.TextStyle(font: boldFont)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  pw.SizedBox(height: 20),

                  // Seat Numbers
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.orange50,
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(5)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Nomor Kursi',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 16,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Wrap(
                          spacing: 10,
                          runSpacing: 5,
                          children: [
                            for (var seatNumber in (ticket.seatNumbers ?? []))
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.blue,
                                  borderRadius: const pw.BorderRadius.all(
                                      pw.Radius.circular(5)),
                                ),
                                child: pw.Text(
                                  seatNumber,
                                  style: pw.TextStyle(
                                    font: font,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Price and Payment Status
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(5)),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Total Pembayaran:',
                              style: pw.TextStyle(font: boldFont),
                            ),
                            pw.Text(
                              _formatCurrency(ticket.totalPrice ?? 0),
                              style: pw.TextStyle(font: boldFont),
                            ),
                          ],
                        ),
                        if (ticket.paymentStatus?.toLowerCase() == 'paid') ...[
                          pw.SizedBox(height: 10),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.green50,
                              borderRadius: const pw.BorderRadius.all(
                                  pw.Radius.circular(5)),
                            ),
                            child: pw.Text(
                              'LUNAS',
                              style: pw.TextStyle(
                                font: boldFont,
                                color: PdfColors.green,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Simpan PDF dengan error handling
      try {
        final output = await getTemporaryDirectory();
        print('Temporary directory: ${output.path}');

        final file = File('${output.path}/ticket_${ticket.bookingCode}.pdf');
        await file.writeAsBytes(await pdf.save());
        print('PDF saved to: ${file.path}');

        // Buka PDF
        final result = await OpenFile.open(file.path);
        print('Open file result: ${result.message}');

        if (result.type != ResultType.done) {
          throw Exception('Gagal membuka file: ${result.message}');
        }
      } catch (e) {
        print('Error saving/opening PDF: $e');
        // Fallback: gunakan printing package untuk preview
        await Printing.layoutPdf(
          onLayout: (format) async => pdf.save(),
          name: 'ticket_${ticket.bookingCode}.pdf',
        );
      }
    } catch (e) {
      print('Error generating PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadTickets,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            width: MediaQuery.of(context).size.width,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : tickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 100),
                            const Icon(
                              Icons.confirmation_number_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Tidak ada tiket aktif',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            TextButton(
                              onPressed: _loadTickets,
                              child: const Text('Refresh'),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tickets.length,
                          itemBuilder: (context, index) {
                            final ticket = tickets[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Kode Booking: ${ticket.bookingCode ?? "N/A"}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                    if (ticket.schedule != null) ...[
                                      Text(
                                        '${ticket.schedule!.origin} → ${ticket.schedule!.destination}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today,
                                              size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Tanggal: ${_formatDate(ticket.schedule!.departureDateTime)}',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time,
                                              size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Jam: ${_formatTime(ticket.schedule!.departureDateTime)}',
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.event_seat, size: 16),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Nomor Kursi:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              if (ticket.seatNumbers != null &&
                                                  ticket.seatNumbers!
                                                      .isNotEmpty) ...[
                                                Wrap(
                                                  spacing: 8.0,
                                                  runSpacing: 4.0,
                                                  children: ticket.seatNumbers!
                                                      .map((seatNumber) {
                                                    print(
                                                        'Rendering seat chip: $seatNumber'); // Debug print
                                                    return Chip(
                                                      label: Text(
                                                        seatNumber,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                          Colors.blue,
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                    );
                                                  }).toList(),
                                                ),
                                              ] else
                                                const Text(
                                                    'Tidak ada data kursi'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Icon(Icons.payment, size: 16),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Total: ${_formatCurrency(ticket.totalPrice ?? 0)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (ticket.paymentStatus?.toLowerCase() ==
                                        'paid') ...[
                                      const Divider(),
                                      const Row(
                                        children: [
                                          Icon(Icons.check_circle,
                                              color: Colors.green, size: 16),
                                          SizedBox(width: 4),
                                          Text(
                                            'Pembayaran berhasil',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (ticket.paymentStatus?.toLowerCase() ==
                                            'pending' &&
                                        ticket.paymentDeadline != null) ...[
                                      const Divider(),
                                      Row(
                                        children: [
                                          Icon(Icons.timer,
                                              color: DateTime.now().isAfter(
                                                      ticket.paymentDeadline!)
                                                  ? Colors.red
                                                  : Colors.orange,
                                              size: 16),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Batas Waktu Pembayaran:',
                                                  style: TextStyle(
                                                    color: DateTime.now()
                                                            .isAfter(ticket
                                                                .paymentDeadline!)
                                                        ? Colors.red
                                                        : Colors.orange,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  _formatDateTime(
                                                      ticket.paymentDeadline!),
                                                  style: TextStyle(
                                                    color: DateTime.now()
                                                            .isAfter(ticket
                                                                .paymentDeadline!)
                                                        ? Colors.red
                                                        : Colors.orange,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    const Divider(),
                                    TextButton.icon(
                                      onPressed: () =>
                                          _generateTicketPDF(ticket),
                                      icon: const Icon(Icons.print),
                                      label: const Text('Cetak E-Ticket'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        text = 'Menunggu Pembayaran';
        break;
      case 'paid':
        color = Colors.green;
        text = 'Sudah Dibayar';
        break;
      case 'active':
        color = Colors.blue;
        text = 'Aktif';
        break;
      case 'completed':
        color = Colors.grey;
        text = 'Selesai';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Dibatalkan';
        break;
      case 'expired':
        color = Colors.red;
        text = 'Kadaluarsa';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Chip(
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: color,
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('HH:mm').format(date);
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  String _getBookingStatus(Booking ticket) {
    if (ticket.paymentStatus?.toLowerCase() == 'paid') {
      // Jika sudah dibayar, tampilkan sebagai "Sudah Dibayar"
      return 'paid';
    } else if (ticket.paymentStatus?.toLowerCase() == 'pending') {
      // Cek apakah sudah melewati batas waktu pembayaran
      if (ticket.paymentDeadline != null &&
          DateTime.now().isAfter(ticket.paymentDeadline!)) {
        return 'expired';
      }
      return 'pending';
    }

    // Gunakan status dari ticket jika ada
    return ticket.status?.toLowerCase() ?? 'pending';
  }
}
