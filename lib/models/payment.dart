import 'dart:convert';

class Payment {
  final String? paymentId;
  final String? bookingId;
  final double? amount;
  final String? method;
  final String? status;
  final DateTime? createdAt;
  final String? virtualAccount;
  final String? paymentCode;
  final DateTime? paymentDeadline;

  Payment({
    this.paymentId,
    this.bookingId,
    this.amount,
    this.method,
    this.status,
    this.createdAt,
    this.virtualAccount,
    this.paymentCode,
    this.paymentDeadline,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['payment_id'],
      bookingId: json['booking_id'],
      amount: json['amount']?.toDouble(),
      method: json['method'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      virtualAccount: json['virtual_account'],
      paymentCode: json['payment_code'],
      paymentDeadline: json['payment_deadline'] != null
          ? DateTime.parse(json['payment_deadline'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'booking_id': bookingId,
      'amount': amount,
      'method': method,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'virtual_account': virtualAccount,
      'payment_code': paymentCode,
      'payment_deadline': paymentDeadline?.toIso8601String(),
    };
  }

  bool isValid() {
    if (paymentDeadline == null) return false;
    return DateTime.now().isBefore(paymentDeadline!);
  }

  bool isCompleted() {
    return status?.toLowerCase() == 'completed';
  }

  bool isPending() {
    return status?.toLowerCase() == 'pending';
  }

  bool isFailed() {
    return status?.toLowerCase() == 'failed';
  }
}
