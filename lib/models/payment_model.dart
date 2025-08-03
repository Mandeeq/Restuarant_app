class Payment {
  final String? id;
  final String orderId;
  final String userId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String status;
  final MpesaDetails? mpesaDetails;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Payment({
    this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    this.currency = 'KES',
    required this.paymentMethod,
    required this.status,
    this.mpesaDetails,
    this.createdAt,
    this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['_id'],
      orderId: json['orderId'],
      userId: json['userId'],
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : json['amount'].toDouble(),
      currency: json['currency'] ?? 'KES',
      paymentMethod: json['paymentMethod'],
      status: json['status'],
      mpesaDetails: json['mpesaDetails'] != null
          ? MpesaDetails.fromJson(json['mpesaDetails'])
          : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'orderId': orderId,
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'status': status,
      if (mpesaDetails != null) 'mpesaDetails': mpesaDetails!.toJson(),
    };
  }
}

class MpesaDetails {
  final String? phoneNumber;
  final String? checkoutRequestId;
  final String? merchantRequestId;
  final String? resultCode;
  final String? resultDesc;
  final String? transactionId;
  final DateTime? transactionDate;

  MpesaDetails({
    this.phoneNumber,
    this.checkoutRequestId,
    this.merchantRequestId,
    this.resultCode,
    this.resultDesc,
    this.transactionId,
    this.transactionDate,
  });

  factory MpesaDetails.fromJson(Map<String, dynamic> json) {
    return MpesaDetails(
      phoneNumber: json['phoneNumber'],
      checkoutRequestId: json['checkoutRequestId'],
      merchantRequestId: json['merchantRequestId'],
      resultCode: json['resultCode'],
      resultDesc: json['resultDesc'],
      transactionId: json['transactionId'],
      transactionDate: json['transactionDate'] != null
          ? DateTime.parse(json['transactionDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (checkoutRequestId != null) 'checkoutRequestId': checkoutRequestId,
      if (merchantRequestId != null) 'merchantRequestId': merchantRequestId,
      if (resultCode != null) 'resultCode': resultCode,
      if (resultDesc != null) 'resultDesc': resultDesc,
      if (transactionId != null) 'transactionId': transactionId,
      if (transactionDate != null)
        'transactionDate': transactionDate!.toIso8601String(),
    };
  }
}

class PaymentResponse {
  final bool success;
  final String message;
  final PaymentData? data;

  PaymentResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? PaymentData.fromJson(json['data']) : null,
    );
  }
}

class PaymentData {
  final String? paymentId;
  final String? checkoutRequestId;
  final String? customerMessage;
  final double? amount;
  final String? status;
  final String? paymentMethod;
  final MpesaDetails? mpesaDetails;
  final DateTime? createdAt;

  PaymentData({
    this.paymentId,
    this.checkoutRequestId,
    this.customerMessage,
    this.amount,
    this.status,
    this.paymentMethod,
    this.mpesaDetails,
    this.createdAt,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      paymentId: json['paymentId'],
      checkoutRequestId: json['checkoutRequestId'],
      customerMessage: json['customerMessage'],
      amount: json['amount'] != null
          ? (json['amount'] is int)
              ? (json['amount'] as int).toDouble()
              : json['amount'].toDouble()
          : null,
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      mpesaDetails: json['mpesaDetails'] != null
          ? MpesaDetails.fromJson(json['mpesaDetails'])
          : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
