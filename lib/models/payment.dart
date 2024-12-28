import 'dart:convert';

class Payment {
  final String? id;
  final String? bookingId;
  final double? amount;
  final String? method;
  final String? virtualAccount;
  final String? paymentProof;
  final DateTime? paymentDeadline;
  final String? status;
  final Map<String, dynamic>? paymentDetails;

  Payment({
    this.id,
    this.bookingId,
    this.amount,
    this.method,
    this.virtualAccount,
    this.paymentProof,
    this.paymentDeadline,
    this.status,
    this.paymentDetails,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'].toString(),
      bookingId: json['booking_id'].toString(),
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      method: json['method'],
      virtualAccount: json['virtual_account'],
      paymentProof: json['payment_proof'],
      paymentDeadline: json['payment_deadline'] != null
          ? DateTime.parse(json['payment_deadline'])
          : null,
      status: json['status'],
      paymentDetails: json['payment_details'] != null
          ? Map<String, dynamic>.from(json['payment_details'])
          : null,
    );
  }
}
