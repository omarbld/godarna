class BookingModel {
  final String id;
  final String propertyId;
  final String tenantId;
  final String hostId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  final double totalPrice;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final String paymentMethod; // 'cash_on_delivery', 'online'
  final String paymentStatus; // 'pending', 'paid', 'failed'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final double? rating;
  final String? review;
  final DateTime? reviewDate;

  BookingModel({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    required this.hostId,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.rating,
    this.review,
    this.reviewDate,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      propertyId: json['property_id'],
      tenantId: json['tenant_id'],
      hostId: json['host_id'],
      checkIn: DateTime.parse(json['check_in']),
      checkOut: DateTime.parse(json['check_out']),
      nights: json['nights'],
      totalPrice: (json['total_price'] as num).toDouble(),
      status: json['status'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      notes: json['notes'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      review: json['review'],
      reviewDate: json['review_date'] != null ? DateTime.parse(json['review_date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'tenant_id': tenantId,
      'host_id': hostId,
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut.toIso8601String(),
      'nights': nights,
      'total_price': totalPrice,
      'status': status,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'notes': notes,
      'rating': rating,
      'review': review,
      'review_date': reviewDate?.toIso8601String(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? propertyId,
    String? tenantId,
    String? hostId,
    DateTime? checkIn,
    DateTime? checkOut,
    int? nights,
    double? totalPrice,
    String? status,
    String? paymentMethod,
    String? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    double? rating,
    String? review,
    DateTime? reviewDate,
  }) {
    return BookingModel(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      tenantId: tenantId ?? this.tenantId,
      hostId: hostId ?? this.hostId,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      nights: nights ?? this.nights,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      reviewDate: reviewDate ?? this.reviewDate,
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'في انتظار التأكيد';
      case 'confirmed':
        return 'مؤكد';
      case 'cancelled':
        return 'ملغي';
      case 'completed':
        return 'مكتمل';
      default:
        return status;
    }
  }

  String get paymentStatusDisplay {
    switch (paymentStatus) {
      case 'pending':
        return 'في انتظار الدفع';
      case 'paid':
        return 'مدفوع';
      case 'failed':
        return 'فشل في الدفع';
      default:
        return paymentStatus;
    }
  }

  String get paymentMethodDisplay {
    switch (paymentMethod) {
      case 'cash_on_delivery':
        return 'الدفع نقداً عند الوصول';
      case 'online':
        return 'الدفع الإلكتروني';
      default:
        return paymentMethod;
    }
  }

  String get displayTotalPrice => '${totalPrice.toStringAsFixed(0)} درهم';
  String get displayNights => '$nights ليلة';
  
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
  
  bool get isPaid => paymentStatus == 'paid';
  bool get isPendingPayment => paymentStatus == 'pending';
  bool get isPaymentFailed => paymentStatus == 'failed';
  
  bool get canBeCancelled => isPending || isConfirmed;
  bool get canBeReviewed => isCompleted && rating == null;
}