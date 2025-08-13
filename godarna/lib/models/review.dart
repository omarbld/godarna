class Review {
  final String id;
  final String listingId;
  final String tenantId;
  final String bookingId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.listingId,
    required this.tenantId,
    required this.bookingId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as String,
      listingId: map['listing_id'] as String,
      tenantId: map['tenant_id'] as String,
      bookingId: map['booking_id'] as String,
      rating: map['rating'] as int? ?? 0,
      comment: map['comment'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}