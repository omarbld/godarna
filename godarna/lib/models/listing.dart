class Listing {
  final String id;
  final String hostId;
  final String title;
  final String description;
  final double pricePerNight;
  final int bedrooms;
  final int bathrooms;
  final int maxGuests;
  final String city;
  final String addressLine;
  final double? lat;
  final double? lng;
  final String? mainImageUrl;
  final double? averageRating;
  final bool isPublished;

  const Listing({
    required this.id,
    required this.hostId,
    required this.title,
    required this.description,
    required this.pricePerNight,
    required this.bedrooms,
    required this.bathrooms,
    required this.maxGuests,
    required this.city,
    required this.addressLine,
    required this.lat,
    required this.lng,
    required this.mainImageUrl,
    required this.averageRating,
    required this.isPublished,
  });

  factory Listing.fromMap(Map<String, dynamic> map) {
    return Listing(
      id: map['id'] as String,
      hostId: map['host_id'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      pricePerNight: (map['price_per_night'] as num?)?.toDouble() ?? 0,
      bedrooms: map['bedrooms'] as int? ?? 0,
      bathrooms: map['bathrooms'] as int? ?? 0,
      maxGuests: map['max_guests'] as int? ?? 0,
      city: map['city'] as String? ?? '',
      addressLine: map['address_line'] as String? ?? '',
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
      mainImageUrl: map['main_image_url'] as String?,
      averageRating: (map['average_rating'] as num?)?.toDouble(),
      isPublished: map['is_published'] as bool? ?? false,
    );
  }
}