import '../../../core/models/artisan_profile.dart';

class B2BMatchedArtisan {
  final String artisanId;
  final String artisanName;
  final String avatarUrl;
  final String craftSpecialization;
  final String location;
  final String state;
  final int yearsOfExperience;
  final double averageRating;
  final int totalReviews;
  final bool isVerified;
  final int matchScore;
  final String matchReason;
  final String feasibility;
  final List<String> highlightTags;

  const B2BMatchedArtisan({
    required this.artisanId,
    required this.artisanName,
    this.avatarUrl = '',
    required this.craftSpecialization,
    this.location = '',
    this.state = '',
    this.yearsOfExperience = 0,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.isVerified = false,
    required this.matchScore,
    required this.matchReason,
    this.feasibility = 'High',
    this.highlightTags = const [],
  });

  factory B2BMatchedArtisan.fromMap(Map<String, dynamic> map) {
    return B2BMatchedArtisan(
      artisanId: (map['artisan_id'] ?? map['artisanId'] ?? '').toString(),
      artisanName: (map['artisan_name'] ?? map['artisanName'] ?? 'Artisan').toString(),
      avatarUrl: (map['avatar_url'] ?? map['avatarUrl'] ?? '').toString(),
      craftSpecialization: (map['craft_specialization'] ?? map['craftSpecialization'] ?? 'Traditional Craft').toString(),
      location: (map['location'] ?? '').toString(),
      state: (map['state'] ?? '').toString(),
      yearsOfExperience: (map['years_of_experience'] ?? map['yearsOfExperience'] ?? 0) is int
          ? (map['years_of_experience'] ?? map['yearsOfExperience'] ?? 0)
          : int.tryParse((map['years_of_experience'] ?? map['yearsOfExperience'] ?? '0').toString()) ?? 0,
      averageRating: (map['average_rating'] ?? map['averageRating'] ?? 0.0) is num
          ? (map['average_rating'] ?? map['averageRating'] ?? 0.0).toDouble()
          : double.tryParse((map['average_rating'] ?? map['averageRating'] ?? '0.0').toString()) ?? 0.0,
      totalReviews: (map['total_reviews'] ?? map['totalReviews'] ?? 0) is int
          ? (map['total_reviews'] ?? map['totalReviews'] ?? 0)
          : int.tryParse((map['total_reviews'] ?? map['totalReviews'] ?? '0').toString()) ?? 0,
      isVerified: (map['is_verified'] ?? map['isVerified'] ?? false) == true,
      matchScore: (map['match_score'] ?? map['matchScore'] ?? 75) is int
          ? (map['match_score'] ?? map['matchScore'] ?? 75)
          : int.tryParse((map['match_score'] ?? map['matchScore'] ?? '75').toString()) ?? 75,
      matchReason: (map['match_reason'] ?? map['matchReason'] ?? '').toString(),
      feasibility: (map['feasibility'] ?? 'High').toString(),
      highlightTags: (map['highlight_tags'] ?? map['highlightTags'] ?? []) is List
          ? (map['highlight_tags'] ?? map['highlightTags'] as List).map((e) => e.toString()).toList()
          : <String>[],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'artisan_id': artisanId,
      'artisan_name': artisanName,
      'avatar_url': avatarUrl,
      'craft_specialization': craftSpecialization,
      'location': location,
      'state': state,
      'years_of_experience': yearsOfExperience,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'is_verified': isVerified,
      'match_score': matchScore,
      'match_reason': matchReason,
      'feasibility': feasibility,
      'highlight_tags': highlightTags,
    };
  }

  ArtisanProfile toArtisanProfile() {
    return ArtisanProfile(
      id: artisanId,
      userId: '',
      name: artisanName,
      avatarUrl: avatarUrl,
      craftSpecialization: craftSpecialization,
      location: location,
      state: state,
      yearsOfExperience: yearsOfExperience,
      averageRating: averageRating,
      totalReviews: totalReviews,
      isVerified: isVerified,
      createdAt: DateTime.now(),
    );
  }
}

class B2BMatchResult {
  final bool success;
  final String requirementSummary;
  final String aiAnalysis;
  final String suggestedCraft;
  final String? estimatedProductionTime;
  final List<B2BMatchedArtisan> matches;
  final int totalMatches;
  final String? modelUsed;
  final String? error;

  const B2BMatchResult({
    this.success = true,
    this.requirementSummary = '',
    this.aiAnalysis = '',
    this.suggestedCraft = '',
    this.estimatedProductionTime,
    this.matches = const [],
    this.totalMatches = 0,
    this.modelUsed,
    this.error,
  });

  factory B2BMatchResult.fromMap(Map<String, dynamic> map) {
    final rawMatches = map['matches'] as List? ?? [];
    return B2BMatchResult(
      success: (map['success'] ?? true) == true,
      requirementSummary: (map['requirement_summary'] ?? map['requirementSummary'] ?? '').toString(),
      aiAnalysis: (map['ai_analysis'] ?? map['aiAnalysis'] ?? '').toString(),
      suggestedCraft: (map['suggested_craft'] ?? map['suggestedCraft'] ?? '').toString(),
      estimatedProductionTime: map['estimated_production_time']?.toString() ?? map['estimatedProductionTime']?.toString(),
      matches: rawMatches.map((m) => B2BMatchedArtisan.fromMap(m as Map<String, dynamic>)).toList(),
      totalMatches: (map['total_matches'] ?? map['totalMatches'] ?? rawMatches.length) as int,
      modelUsed: map['model_used']?.toString() ?? map['modelUsed']?.toString(),
      error: map['error']?.toString(),
    );
  }
}
