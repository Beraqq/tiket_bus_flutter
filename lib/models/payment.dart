import 'dart:convert';

class Payment {
  final int? id;
  final int? bookingId;
  final double? amount;
  final String? method;
  final String? virtualAccount;
  final String? paymentProof;
  final DateTime? paymentDeadline;
  final String? status;
  final Map<String, dynamic>? paymentDetails;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.createdAt,
    this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      bookingId: json['booking_id'],
      amount: json['amount']?.toDouble(),
      method: json['method'],
      virtualAccount: json['virtual_account'],
      paymentProof: json['payment_proof'],
      paymentDeadline: json['payment_deadline'] != null
          ? DateTime.parse(json['payment_deadline'])
          : null,
      status: json['status'],
      paymentDetails: json['payment_details'] != null
          ? jsonDecode(json['payment_details'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
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
      'payment_details':
          paymentDetails != null ? jsonEncode(paymentDetails) : null,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
