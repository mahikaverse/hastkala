class CraftImageHelper {
  static const List<String> _allCraftImages = [
    'assets/craft/craft_blue_pottery_vase.jpg',
    'assets/craft/craft_block_printed_textile.jpg',
    'assets/craft/craft_terracotta_pot.jpg',
    'assets/craft/craft_bamboo_basket.jpg',
    'assets/craft/craft_wooden_carved_box.jpg',
    'assets/craft/craft_handwoven_fabric.jpg',
    'assets/craft/craft_brass_metal.jpg',
    'assets/craft/craft_marble_inlay.jpg',
    'assets/craft/craft_lac_bangles.jpg',
    'assets/craft/craft_papier_mache.jpg',
    'assets/craft/craft_chikankari_fabric.jpg',
    'assets/craft/craft_madhubani_painting.jpg',
  ];

  static const Map<String, String> _craftPriorityMap = {
    'blue pottery': 'assets/craft/craft_blue_pottery_vase.jpg',
    'block print': 'assets/craft/craft_block_printed_textile.jpg',
    'block printing': 'assets/craft/craft_block_printed_textile.jpg',
    'block printed': 'assets/craft/craft_block_printed_textile.jpg',
    'textile': 'assets/craft/craft_block_printed_textile.jpg',
    'terracotta': 'assets/craft/craft_terracotta_pot.jpg',
    'terracotta pot': 'assets/craft/craft_terracotta_pot.jpg',
    'pottery': 'assets/craft/craft_terracotta_pot.jpg',
    'ceramics': 'assets/craft/craft_terracotta_pot.jpg',
    'pottery & ceramics': 'assets/craft/craft_terracotta_pot.jpg',
    'bamboo': 'assets/craft/craft_bamboo_basket.jpg',
    'bamboo & cane': 'assets/craft/craft_bamboo_basket.jpg',
    'cane': 'assets/craft/craft_bamboo_basket.jpg',
    'wooden': 'assets/craft/craft_wooden_carved_box.jpg',
    'woodcarving': 'assets/craft/craft_wooden_carved_box.jpg',
    'wood craft': 'assets/craft/craft_wooden_carved_box.jpg',
    'wood': 'assets/craft/craft_wooden_carved_box.jpg',
    'handloom': 'assets/craft/craft_handwoven_fabric.jpg',
    'handwoven': 'assets/craft/craft_handwoven_fabric.jpg',
    'weaving': 'assets/craft/craft_handwoven_fabric.jpg',
    'fabric': 'assets/craft/craft_handwoven_fabric.jpg',
    'cotton': 'assets/craft/craft_handwoven_fabric.jpg',
    'silk': 'assets/craft/craft_handwoven_fabric.jpg',
    'saree': 'assets/craft/craft_handwoven_fabric.jpg',
    'dupatta': 'assets/craft/craft_block_printed_textile.jpg',
    'vase': 'assets/craft/craft_blue_pottery_vase.jpg',
    'bowl': 'assets/craft/craft_terracotta_pot.jpg',
    'planter': 'assets/craft/craft_terracotta_pot.jpg',
    'lamp': 'assets/craft/craft_bamboo_basket.jpg',
    'brass': 'assets/craft/craft_brass_metal.jpg',
    'bronze': 'assets/craft/craft_brass_metal.jpg',
    'dhokra': 'assets/craft/craft_brass_metal.jpg',
    'metal': 'assets/craft/craft_brass_metal.jpg',
    'marble': 'assets/craft/craft_marble_inlay.jpg',
    'marble inlay': 'assets/craft/craft_marble_inlay.jpg',
    'stone': 'assets/craft/craft_marble_inlay.jpg',
    'lac': 'assets/craft/craft_lac_bangles.jpg',
    'lac bangles': 'assets/craft/craft_lac_bangles.jpg',
    'bangles': 'assets/craft/craft_lac_bangles.jpg',
    'jewelry': 'assets/craft/craft_lac_bangles.jpg',
    'jewellery': 'assets/craft/craft_lac_bangles.jpg',
    'papier': 'assets/craft/craft_papier_mache.jpg',
    'papier-mache': 'assets/craft/craft_papier_mache.jpg',
    'paper mache': 'assets/craft/craft_papier_mache.jpg',
    'chikankari': 'assets/craft/craft_chikankari_fabric.jpg',
    'embroidery': 'assets/craft/craft_chikankari_fabric.jpg',
    'madhubani': 'assets/craft/craft_madhubani_painting.jpg',
    'painting': 'assets/craft/craft_madhubani_painting.jpg',
    'art': 'assets/craft/craft_madhubani_painting.jpg',
    'home decor': 'assets/craft/craft_blue_pottery_vase.jpg',
    'kitchen & dining': 'assets/craft/craft_terracotta_pot.jpg',
  };

  static String _getBestMatch(String searchText) {
    for (final entry in _craftPriorityMap.entries) {
      if (searchText.contains(entry.key)) {
        return entry.value;
      }
    }
    return '';
  }

  static int _hashString(String input) {
    var hash = 0;
    for (var i = 0; i < input.length; i++) {
      hash = ((hash << 5) - hash + input.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    return hash.abs();
  }

  static String getImageForProduct({
    required String productId,
    String? craftType,
    String? category,
    String? name,
  }) {
    final searchText = '${name ?? ''} ${craftType ?? ''} ${category ?? ''}'.toLowerCase().trim();

    if (searchText.isNotEmpty) {
      final bestMatch = _getBestMatch(searchText);
      if (bestMatch.isNotEmpty) {
        return bestMatch;
      }
    }

    if (productId.isNotEmpty || name != null) {
      final index = _hashString(productId.isNotEmpty ? productId : name!) % _allCraftImages.length;
      return _allCraftImages[index];
    }

    return _allCraftImages[0];
  }

  static String getImageForCraft(String? craftType, String? category) {
    final searchText = '${craftType ?? ''} ${category ?? ''}'.toLowerCase().trim();
    if (searchText.isEmpty) return _allCraftImages[0];

    final bestMatch = _getBestMatch(searchText);
    return bestMatch.isNotEmpty ? bestMatch : _allCraftImages[0];
  }
}
