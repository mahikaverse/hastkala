import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../models/artisan_profile.dart';

class ArtisanImageHelper {
  static const String defaultArtisanAsset = 'assets/artisans/artisan_default.jpg';

  static const List<String> _foreignerImagePatterns = [
    'photo-1494790108755',
    'photo-1507003211169',
    'photo-1438761681033',
    'photo-1472099645785',
    'photo-1544005313-94ddf0286df2',
    'photo-1534528741775',
    'photo-1506794778202',
  ];

  /// Checks if a given image URL is a known western/foreigner stock photo
  static bool isForeignerOrInvalidPhoto(String? url) {
    if (url == null || url.trim().isEmpty) return true;
    final clean = url.trim().toLowerCase();
    if (!clean.startsWith('http://') && !clean.startsWith('https://')) return true;
    for (final pattern in _foreignerImagePatterns) {
      if (clean.contains(pattern)) return true;
    }
    return false;
  }

  /// Maps an artisan to an authentic Indian artisan local asset
  static String getAssetForArtisan({
    String? name,
    String? craftType,
    String? artisanId,
  }) {
    final lowerName = (name ?? '').toLowerCase();
    final lowerCraft = (craftType ?? '').toLowerCase();
    final lowerId = (artisanId ?? '').toLowerCase();

    if (lowerName.contains('ramesh') || lowerId.contains('000000000002') || (lowerCraft.contains('blue pottery') && lowerName.contains('ramesh'))) {
      return 'assets/artisans/artisan_ramesh.jpg';
    }
    if (lowerName.contains('meera') || lowerId.contains('000000000001') || lowerCraft.contains('block print')) {
      return 'assets/artisans/artisan_meera.jpg';
    }
    if (lowerName.contains('kavita') || lowerId.contains('000000000003') || lowerCraft.contains('silk') || lowerCraft.contains('banarasi')) {
      return 'assets/artisans/artisan_kavita.jpg';
    }
    if (lowerName.contains('arjun') || lowerId.contains('000000000004') || lowerCraft.contains('bamboo') || lowerCraft.contains('cane')) {
      return 'assets/artisans/artisan_arjun.jpg';
    }
    if (lowerName.contains('sita') || lowerId.contains('000000000005') || lowerCraft.contains('woodcarving') || lowerCraft.contains('wood carving')) {
      return 'assets/artisans/artisan_sita.jpg';
    }
    if (lowerName.contains('dangi') || lowerId.contains('d11d5f72')) {
      return 'assets/artisans/artisan_dangi.jpg';
    }
    if (lowerName.contains('anand') || lowerId.contains('446655440001')) {
      return 'assets/artisans/artisan_anand.jpg';
    }

    if (lowerCraft.contains('pottery') || lowerCraft.contains('terracotta') || lowerCraft.contains('ceramics')) {
      return 'assets/artisans/artisan_ramesh.jpg';
    }
    if (lowerCraft.contains('weaver') || lowerCraft.contains('weaving') || lowerCraft.contains('handloom') || lowerCraft.contains('textile')) {
      return 'assets/artisans/artisan_kavita.jpg';
    }
    if (lowerCraft.contains('wood') || lowerCraft.contains('metal') || lowerCraft.contains('brass')) {
      return 'assets/artisans/artisan_sita.jpg';
    }

    return defaultArtisanAsset;
  }

  /// Builds a rounded artisan avatar widget showing authentic Indian artisan photos
  static Widget buildAvatar({
    required String name,
    String? avatarUrl,
    String? craftType,
    String? artisanId,
    double radius = 28,
    Border? border,
  }) {
    final fallbackAsset = getAssetForArtisan(
      name: name,
      craftType: craftType,
      artisanId: artisanId,
    );

    final bool useNetwork = !isForeignerOrInvalidPhoto(avatarUrl);

    Widget imageWidget;
    if (useNetwork) {
      imageWidget = Image.network(
        avatarUrl!,
        fit: BoxFit.cover,
        width: radius * 2,
        height: radius * 2,
        errorBuilder: (_, __, ___) => Image.asset(
          fallbackAsset,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
        ),
      );
    } else {
      imageWidget = Image.asset(
        fallbackAsset,
        fit: BoxFit.cover,
        width: radius * 2,
        height: radius * 2,
      );
    }

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border ?? Border.all(color: AppColors.terracotta.withValues(alpha: 0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(child: imageWidget),
    );
  }

  /// Returns authentic, rich story of the Indian artisan
  static String getArtisanStory(ArtisanProfile artisan) {
    if (artisan.craftStory.trim().isNotEmpty && artisan.craftStory.trim().length > 25) {
      return artisan.craftStory.trim();
    }

    final name = artisan.name.trim();
    final craft = artisan.craftSpecialization.isNotEmpty ? artisan.craftSpecialization : 'Traditional Handicrafts';
    final location = artisan.location.isNotEmpty ? artisan.location : 'India';
    final exp = artisan.yearsOfExperience > 0 ? '${artisan.yearsOfExperience} years' : 'over two decades';

    final lowerName = name.toLowerCase();
    if (lowerName.contains('ramesh')) {
      return 'Blue pottery is an alchemy of quartz stone powder, Fuller\'s earth, and natural gum. My grandfather was among the handful of artisans who revived Jaipur blue pottery. Sitting barefoot at my traditional wheel, I mold each vase, plate, and bowl by hand. When the kiln cools down after three days of slow wood firing, seeing the brilliant cobalt blue emerge feels like a blessing from the divine.';
    }
    if (lowerName.contains('meera')) {
      return 'I was born into a family of Chippa community block printers in Sanganer. From age 10, my grandmother taught me how to extract vibrant reds from madder root and deep blues from natural indigo. Every teakwood block carved by my brothers carries patterns handed down across six generations. In our village workshop, we dry hand-printed cotton fabrics under the open desert sun. Each dupatta and bedsheet takes hours of patience, keeping the soul of Rajasthani craft alive.';
    }
    if (lowerName.contains('kavita')) {
      return 'In the narrow lanes of Madanpura in Varanasi, the rhythmic clack-clack of pit looms has been the soundtrack of my life. My father sat at the loom before sunrise, and I grew up sorting pure mulberry silk threads and gold zari. A single bridal Banarasi saree takes up to 40 days of painstaking hand weaving. When a bride wears our saree, she wears decades of our family\'s heritage and prayers.';
    }
    if (lowerName.contains('arjun')) {
      return 'In our lush village along the Brahmaputra, bamboo is life itself. I learned from the elders of the Bodo community how to select mature bamboo during autumn, treat it naturally with water and smoke, and split it into delicate strands. Every lampshade, basket, and home decor piece I craft is 100% biodegradable and breathes the tranquility of Assam\'s forests.';
    }
    if (lowerName.contains('sita')) {
      return 'Woodcarving has been our family\'s worship for generations in Thrissur. Working with fragrant sandalwood, seasoned rosewood, and teak, my hands have shaped temple doors, Kathakali motifs, and intricate jewelry boxes. Every chisel stroke requires absolute concentration and reverence for the wood. Even in modern times, I never use power tools; each curve is sculpted by chisel and mallet.';
    }
    if (lowerName.contains('dangi')) {
      return 'Growing up in rural Madhya Pradesh, I watched local artisans breathe life into simple raw earth and natural fibers. I established my craft workshop to support underprivileged village craftspeople and keep indigenous handcraft traditions alive. Every handcrafted item we produce provides direct livelihood to rural artisan families and carries forward authentic Indian folk traditions.';
    }
    if (lowerName.contains('anand')) {
      return 'Pottery was passed to me as my most precious inheritance. With over 20 years dedicated to shaping terracotta and ceramic vessels, I spend my days mixing river clay and crafting pottery for homes across India. In every teapot, planter, and decorative tile, you can feel the warmth of human hands that machine manufacturing could never replace.';
    }

    return 'Crafting has been the heartbeat of our family for generations in $location. For $exp, I have dedicated my life to $craft, keeping ancestral techniques alive without modern shortcuts. Each piece is molded, carved, or woven entirely by hand with deep respect for natural materials. By choosing our handmade creations, you directly support rural artisan households and sustain India\'s rich craft heritage.';
  }
}
