class ArtisanProfile {
  final String id;
  final String userId;
  final String name;
  final String avatarUrl;
  final String bio;
  final String craftSpecialization;
  final String location;
  final String state;
  final int yearsOfExperience;
  final String craftStory;
  final String? contactEmail;
  final String? contactPhone;
  final String? website;
  final String? instagram;
  final String? facebook;
  final bool isVerified;
  final DateTime createdAt;
  final int followersCount;
  final int productsCount;
  final double averageRating;
  final int totalReviews;

  const ArtisanProfile({
    required this.id,
    required this.userId,
    required this.name,
    this.avatarUrl = '',
    this.bio = '',
    this.craftSpecialization = '',
    this.location = '',
    this.state = '',
    this.yearsOfExperience = 0,
    this.craftStory = '',
    this.contactEmail,
    this.contactPhone,
    this.website,
    this.instagram,
    this.facebook,
    this.isVerified = false,
    required this.createdAt,
    this.followersCount = 0,
    this.productsCount = 0,
    this.averageRating = 0.0,
    this.totalReviews = 0,
  });

  ArtisanProfile copyWith({
    String? name,
    String? avatarUrl,
    String? bio,
    String? craftSpecialization,
    String? location,
    String? state,
    int? yearsOfExperience,
    String? craftStory,
    String? contactEmail,
    String? contactPhone,
    String? website,
    String? instagram,
    String? facebook,
    bool? isVerified,
    int? followersCount,
    int? productsCount,
    double? averageRating,
    int? totalReviews,
  }) {
    return ArtisanProfile(
      id: id,
      userId: userId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      craftSpecialization: craftSpecialization ?? this.craftSpecialization,
      location: location ?? this.location,
      state: state ?? this.state,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      craftStory: craftStory ?? this.craftStory,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      website: website ?? this.website,
      instagram: instagram ?? this.instagram,
      facebook: facebook ?? this.facebook,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
      followersCount: followersCount ?? this.followersCount,
      productsCount: productsCount ?? this.productsCount,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'craftSpecialization': craftSpecialization,
      'location': location,
      'state': state,
      'yearsOfExperience': yearsOfExperience,
      'craftStory': craftStory,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'website': website,
      'instagram': instagram,
      'facebook': facebook,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'followersCount': followersCount,
      'productsCount': productsCount,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      if (id.isNotEmpty && !id.startsWith('ap_')) 'id': id,
      if (userId.isNotEmpty) 'user_id': userId,
      'name': name,
      'avatar_url': avatarUrl,
      'bio': bio,
      'craft_specialization': craftSpecialization,
      'location': location,
      'state': state,
      'years_of_experience': yearsOfExperience,
      'craft_story': craftStory,
      if (contactEmail != null) 'contact_email': contactEmail,
      if (contactPhone != null) 'contact_phone': contactPhone,
      if (website != null) 'website': website,
      if (instagram != null) 'instagram': instagram,
      if (facebook != null) 'facebook': facebook,
      'is_verified': isVerified,
    };
  }

  factory ArtisanProfile.fromMap(Map<String, dynamic> map) {
    return ArtisanProfile(
      id: (map['id'] ?? '').toString(),
      userId: (map['userId'] ?? map['user_id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      avatarUrl: (map['avatarUrl'] ?? map['avatar_url'] ?? '').toString(),
      bio: (map['bio'] ?? '').toString(),
      craftSpecialization: (map['craftSpecialization'] ?? map['craft_specialization'] ?? '').toString(),
      location: (map['location'] ?? '').toString(),
      state: (map['state'] ?? '').toString(),
      yearsOfExperience: int.tryParse((map['yearsOfExperience'] ?? map['years_of_experience'] ?? 0).toString()) ?? 0,
      craftStory: (map['craftStory'] ?? map['craft_story'] ?? '').toString(),
      contactEmail: map['contactEmail'] ?? map['contact_email'],
      contactPhone: map['contactPhone'] ?? map['contact_phone'],
      website: map['website'],
      instagram: map['instagram'],
      facebook: map['facebook'],
      isVerified: map['isVerified'] ?? map['is_verified'] ?? false,
      createdAt: DateTime.tryParse((map['createdAt'] ?? map['created_at'] ?? '').toString()) ?? DateTime.now(),
      followersCount: int.tryParse((map['followersCount'] ?? map['followers_count'] ?? 0).toString()) ?? 0,
      productsCount: int.tryParse((map['productsCount'] ?? map['products_count'] ?? 0).toString()) ?? 0,
      averageRating: double.tryParse((map['averageRating'] ?? map['average_rating'] ?? 0.0).toString()) ?? 0.0,
      totalReviews: int.tryParse((map['totalReviews'] ?? map['total_reviews'] ?? 0).toString()) ?? 0,
    );
  }
}
