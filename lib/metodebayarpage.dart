import 'package:flutter/material.dart';
import 'package:flutter_application_projectmp/pembayaranpage.dart';

class PaymentPage extends StatefulWidget {
  final String type;
  final String code;
  final String departureLocation;
  final String arrivalLocation;
  final String departureDateTime;
  final String arrivalDateTime;
  final String price;
  final List<int> selectedSeats;

  const PaymentPage({super.key, 
    required this.type,
    required this.code,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.departureDateTime,
    required this.arrivalDateTime,
    required this.price,
    required this.selectedSeats,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool isAgreed = false;
  String selectedPaymentMethod = "";
  String selectedSubMethod = "";

  final Map<String, List<String>> paymentSubMethods = {
    "Transfer Bank": [
      "Bank Mandiri",
      "Bank BRI",
      "Bank CIMB Niaga",
      "Bank BNI"
    ],
    "E-Wallet": ["DANA", "OVO", "GoPay", "ShopeePay"],
    "Retail Payments": ["Alfamart", "Alfamidi", "Indomaret"],
  };

  int get totalPrice {
    final seatPrice =
        int.parse(widget.price.replaceAll('Rp', '').replaceAll('.', '').trim());
    return seatPrice * widget.selectedSeats.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        actions: const [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Image(
                  image: AssetImage('assets/images/gambar2.png'),
                  height: 50,
                  width: 50,
                ),
              ),
              SizedBox(width: 8),
              Text(
                "The_Buzee.com",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
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
              _buildInfoCard(),
              const SizedBox(height: 16),
              const SectionTitle(title: "Metode Pembayaran"),
              _buildPaymentMethodsDropdown(),
              if (selectedPaymentMethod.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    SectionTitle(
                        title: "Pilih Sub-Metode ($selectedPaymentMethod)"),
                    _buildSubMethods(),
                  ],
                ),
              const SizedBox(height: 16),
              const SectionTitle(title: "Voucher The_Buzee.com"),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Fitur Voucher belum tersedia")),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text("Pilih Voucher"),
                ),
              ),
              const SizedBox(height: 16),
              const SectionTitle(title: "Rincian Harga"),
              PriceDetailRow(label: widget.type, price: widget.price),
              PriceDetailRow(
                  label: "${widget.selectedSeats.length} Penumpang", price: ""),
              const Divider(thickness: 1),
              PriceDetailRow(
                  label: "Total Bayar",
                  price: "Rp ${totalPrice.toString()}",
                  isBold: true),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: isAgreed,
                    onChanged: (value) {
                      setState(() {
                        isAgreed = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Buka Syarat dan Ketentuan")),
                        );
                      },
                      child: const Text(
                        "Dengan ini, Saya telah menyetujui Syarat & Ketentuan dan Kebijakan Privasi RI Plus",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAgreed &&
                            selectedPaymentMethod.isNotEmpty &&
                            selectedSubMethod.isNotEmpty
                        ? Colors.blue
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: isAgreed &&
                          selectedPaymentMethod.isNotEmpty &&
                          selectedSubMethod.isNotEmpty
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                orderCode: widget.code,
                                virtualAccount: selectedSubMethod,
                                totalPayment: totalPrice.toString(),
                                paymentDeadline: "12 Desember 2024, 23:59",
                                paymentMethod: selectedPaymentMethod,
                              ),
                            ),
                          );
                        }
                      : null,
                  child: const Text(
                    "Lanjutkan",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${widget.departureLocation}\n${widget.departureDateTime}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const Icon(Icons.arrow_forward),
              Expanded(
                child: Text(
                  '${widget.arrivalLocation}\n${widget.arrivalDateTime}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsDropdown() {
    final methods = ["Transfer Bank", "Retail Payments", "E-Wallet"];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
        color: Colors.blue[50],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.payment, size: 20, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                selectedPaymentMethod.isEmpty
                    ? "Pilih Metode"
                    : selectedPaymentMethod,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value:
                  selectedPaymentMethod.isEmpty ? null : selectedPaymentMethod,
              hint: const Text("Pilih", style: TextStyle(color: Colors.grey)),
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (String? value) {
                setState(() {
                  selectedPaymentMethod = value!;
                  selectedSubMethod = ""; // Reset pilihan sub-metode
                });
              },
              items: methods.map((String method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubMethods() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
        color: Colors.blue[50],
      ),
      child: DropdownButton<String>(
        value: selectedSubMethod.isEmpty ? null : selectedSubMethod,
        hint: const Text("Pilih Sub-Metode",
            style: TextStyle(color: Colors.grey)),
        icon: const Icon(Icons.arrow_drop_down),
        onChanged: (String? value) {
          setState(() {
            selectedSubMethod = value!;
          });
        },
        items:
            paymentSubMethods[selectedPaymentMethod]!.map((String subMethod) {
          return DropdownMenuItem<String>(
            value: subMethod,
            child: Row(
              children: [
                // Logo untuk sub-metode Transfer Bank
                if (selectedPaymentMethod == "Transfer Bank" &&
                    subMethod == "Bank Mandiri")
                  Image.asset('assets/images/logo_mandiri.png',
                      width: 35, height: 35),
                if (selectedPaymentMethod == "Transfer Bank" &&
                    subMethod == "Bank BRI")
                  Image.asset('assets/images/logo_bri.png',
                      width: 35, height: 35),
                if (selectedPaymentMethod == "Transfer Bank" &&
                    subMethod == "Bank CIMB Niaga")
                  Image.asset('assets/images/logo_cimbniaga.png',
                      width: 35, height: 35),
                if (selectedPaymentMethod == "Transfer Bank" &&
                    subMethod == "Bank BNI")
                  Image.asset('assets/images/logo_bni.png',
                      width: 35, height: 35),
                // Conditional check to display logo for Retail Payments
                if (selectedPaymentMethod == "Retail Payments" &&
                    subMethod == "Alfamart")
                  Image.asset('assets/images/logo_alfamart.png',
                      width: 35, height: 35),
                if (selectedPaymentMethod == "Retail Payments" &&
                    subMethod == "Alfamidi")
                  Image.asset('assets/images/logo_alfamidi.png',
                      width: 35, height: 35),
                if (selectedPaymentMethod == "Retail Payments" &&
                    subMethod == "Indomaret")
                  Image.asset('assets/images/logo_indomaret.png',
                      width: 35, height: 35),
                // Logo untuk sub-metode E-Wallet
                if (selectedPaymentMethod == "E-Wallet" && subMethod == "DANA")
                  Image.asset('assets/images/logo_dana.png',
                      width: 35, height: 35),
                if (selectedPaymentMethod == "E-Wallet" && subMethod == "OVO")
                  Image.asset('assets/images/logo_ovo.png',
                      width: 35, height: 35),
                if (selectedPaymentMethod == "E-Wallet" && subMethod == "GoPay")
                  Image.asset('assets/images/logo_gopay.png',
                      width: 35, height: 35),
                if (selectedPaymentMethod == "E-Wallet" &&
                    subMethod == "ShopeePay")
                  Image.asset('assets/images/logo_shoppepay.png',
                      width: 35, height: 35),
                const SizedBox(width: 8),
                Text(subMethod),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }
}

class PriceDetailRow extends StatelessWidget {
  final String label;
  final String price;
  final bool isBold;
  const PriceDetailRow({
    super.key,
    required this.label,
    required this.price,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          price,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
