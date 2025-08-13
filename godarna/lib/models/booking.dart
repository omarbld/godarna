class Booking {
  final String id;
  final String tenantId;
  final String listingId;
  final DateTime startDate;
  final DateTime endDate;
  final int numGuests;
  final double totalPrice;
  final String status; // pending | confirmed | cancelled | completed
  final String paymentMethod; // cod | online
  final String paymentStatus; // unpaid | paid | failed | refunded | pending

  const Booking({
    required this.id,
    required this.tenantId,
    required this.listingId,
    required this.startDate,
    required this.endDate,
    required this.numGuests,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as String,
      tenantId: map['tenant_id'] as String,
      listingId: map['listing_id'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      numGuests: map['num_guests'] as int? ?? 1,
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0,
      status: map['status'] as String? ?? 'pending',
      paymentMethod: map['payment_method'] as String? ?? 'cod',
      paymentStatus: map['payment_status'] as String? ?? 'pending',
    );
  }
}