class UserProfile {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String role; // tenant | host | admin

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.avatarUrl,
    required this.role,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      fullName: map['full_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      role: map['role'] as String? ?? 'tenant',
    );
  }
}