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
      id: json['id']?.toString(),
      bookingId: json['booking_id']?.toString(),
      amount: json['amount'] != null
          ? double.tryParse(json['amount'].toString())
          : null,
      method: json['method']?.toString(),
      virtualAccount: json['virtual_account']?.toString(),
      paymentProof: json['payment_proof']?.toString(),
      paymentDeadline: json['payment_deadline'] != null
          ? DateTime.tryParse(json['payment_deadline'].toString())
          : null,
      status: json['status']?.toString(),
      paymentDetails: json['payment_details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'amount': amount,
      'method': method,
      'virtual_account': virtualAccount,
      'payment_proof': paymentProof,
      'payment_deadline': paymentDeadline?.toIso8601String(),
      'status': status,
      'payment_details': paymentDetails,
    };
  }
}
