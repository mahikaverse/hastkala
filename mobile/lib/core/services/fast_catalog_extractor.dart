/// Ultra-fast on-device handicraft catalog extractor
/// Operates in < 5ms without requiring network or heavy AI.
class FastCatalogExtractor {
  static Map<String, dynamic> extract(String transcript) {
    final t = transcript.trim();
    if (t.isEmpty) {
      return {
        'product_name': null,
        'category': null,
        'material': null,
        'craft': null,
        'color': null,
        'size': null,
        'weight': null,
        'quantity': null,
        'production_capacity': null,
        'making_time': null,
        'making_process': null,
        'location': null,
        'price': null,
        'craft_story': null,
        'artisan_intro': null,
      };
    }

    final lower = t.toLowerCase();

    // 1. Price
    int? price;
    final pricePatterns = [
      RegExp(r'(?:price|keemat|kimat|rate|cost|lagat|bhav)\s*(?:is|hai|h|:)?\s*₹?\s*(\d[\d,]*)'),
      RegExp(r'₹\s*(\d[\d,]*)'),
      RegExp(r'(\d[\d,]*)\s*(?:rupees|rupaye|rupee|rs\.?|r[ps]\b)'),
      RegExp(r'(?:bika|bechenge|denge|milega|rakha|rakhi)\s*(\d[\d,]*)\s*(?:mein|me|ka|ki)'),
    ];
    for (final p in pricePatterns) {
      final m = p.firstMatch(lower);
      if (m != null) {
        price = int.tryParse(m.group(1)!.replaceAll(',', ''));
        if (price != null) break;
      }
    }

    // 2. Material
    final materials = <String, List<String>>{
      'Terracotta': ['terracotta', 'teracota', 'pakki mitti', 'baked clay'],
      'Clay': ['clay', 'mitti', 'chikni mitti', 'kali mitti', 'lal mitti'],
      'Bamboo': ['bamboo', 'baans', 'bans', 'cane', 'bent'],
      'Teak Wood': ['teak', 'sagwan', 'saagwan'],
      'Sheesham Wood': ['sheesham', 'shisham', 'rosewood'],
      'Wood': ['wood', 'wooden', 'lakdi', 'lakadi', 'kashth'],
      'Silk': ['silk', 'reshmi', 'resham', 'tussar', 'muga', 'chanderi', 'banarasi silk'],
      'Cotton': ['cotton', 'sooti', 'suti', 'khadi', 'malmal'],
      'Brass': ['brass', 'peetal', 'pital'],
      'Copper': ['copper', 'tamba', 'taamba'],
      'Bronze': ['bronze', 'kansa', 'kaansa'],
      'Marble': ['marble', 'sangmarmar', 'patthar', 'stone'],
      'Jute': ['jute', 'patson', 'san'],
      'Leather': ['leather', 'chamda', 'chamde'],
      'Ceramic': ['ceramic', 'porcelain', 'chini mitti'],
      'Glass': ['glass', 'kaanch', 'kanch'],
      'Metal': ['metal', 'loha', 'iron'],
      'Wool': ['wool', 'oon', 'pashmina', 'cashmere'],
    };

    String? material;
    for (final entry in materials.entries) {
      for (final kw in entry.value) {
        if (_containsWord(lower, kw)) {
          material = entry.key;
          break;
        }
      }
      if (material != null) break;
    }

    // 3. Category
    final categories = <String, List<String>>{
      'Pottery & Ceramics': ['pottery', 'matka', 'pot', 'diya', 'vase', 'kulhad', 'ceramic', 'clay', 'terracotta', 'mitti', 'cup', 'kullhad'],
      'Woodwork': ['wood', 'wooden', 'furniture', 'carving', 'toy', 'sheesham', 'lakdi', 'box', 'jharokha', 'mandir'],
      'Textiles & Handloom': ['saree', 'dupatta', 'kurta', 'shawl', 'fabric', 'cloth', 'weaving', 'handloom', 'chikankari', 'cotton', 'silk', 'embroidery', 'stole', 'bedsheet', 'chiffon'],
      'Jewelry & Accessories': ['jewelry', 'jewellery', 'necklace', 'earring', 'bangle', 'ring', 'pendant', 'jhumka', 'haar', 'churi', 'kangan', 'payal'],
      'Metal Craft': ['metal', 'brass', 'copper', 'bronze', 'bell', 'dhokra', 'bidri', 'peetal', 'diya', 'lamp'],
      'Paintings & Art': ['painting', 'art', 'madhubani', 'warli', 'pattachitra', 'canvas', 'chitra', 'portrait', 'tanjore'],
      'Bamboo & Cane': ['bamboo', 'cane', 'wicker', 'tokri', 'basket', 'baans', 'mat'],
      'Leather Craft': ['leather', 'bag', 'wallet', 'jooti', 'mojari', 'chamda', 'belt'],
      'Stone Craft': ['stone', 'marble', 'sculpture', 'murti', 'idol', 'carved stone'],
    };

    String? category;
    for (final entry in categories.entries) {
      for (final kw in entry.value) {
        if (_containsWord(lower, kw)) {
          category = entry.key;
          break;
        }
      }
      if (category != null) break;
    }

    // 4. Craft Technique
    final crafts = <String, List<String>>{
      'Blue Pottery': ['blue pottery'],
      'Terracotta Craft': ['terracotta', 'teracota', 'pakki mitti'],
      'Hand Carving': ['hand carving', 'carved', 'nakkashi', 'carving', 'tarasha'],
      'Hand Painted': ['hand painted', 'painted', 'rangoli', 'paint kiya', 'chitrakala'],
      'Handloom Weaving': ['handloom', 'weaving', 'bunkar', 'bunai', 'hath kargha', 'buna hua'],
      'Chikankari': ['chikankari', 'chikan'],
      'Block Printing': ['block print', 'ajrakh', 'dabu', 'bagru', 'chhappai', 'thappa'],
      'Madhubani Painting': ['madhubani', 'mithila'],
      'Warli Art': ['warli'],
      'Pattachitra': ['pattachitra', 'patachitra'],
      'Dhokra Art': ['dhokra', 'dokra'],
      'Bidriware': ['bidri'],
      'Zardozi Embroidery': ['zardozi', 'zari', 'gota patti', 'aari'],
      'Wheel Pottery': ['wheel', 'chaak', 'chaak par', 'mitti ka kaam'],
      'Cane Weaving': ['cane weaving', 'tokri bunai', 'baans bunai'],
      'Handcrafted': ['handcrafted', 'handmade', 'haath se', 'hath se', 'hastshilp', 'hastkala'],
    };

    String? craft;
    for (final entry in crafts.entries) {
      for (final kw in entry.value) {
        if (_containsWord(lower, kw)) {
          craft = entry.key;
          break;
        }
      }
      if (craft != null) break;
    }

    // 5. Color
    final colors = <String, List<String>>{
      'Blue': ['blue', 'neela', 'neeli', 'aasmaani'],
      'Red': ['red', 'lal', 'laal'],
      'Green': ['green', 'hara', 'hari'],
      'Yellow': ['yellow', 'peela', 'peeli'],
      'Black': ['black', 'kala', 'kali'],
      'White': ['white', 'safed', 'chitta'],
      'Gold': ['gold', 'golden', 'sunehra', 'sunhara', 'zari'],
      'Silver': ['silver', 'chandi', 'rupehla'],
      'Brown': ['brown', 'bhoora', 'bhoori'],
      'Pink': ['pink', 'gulabi'],
      'Orange': ['orange', 'narangi', 'kesariya'],
      'Multicolor': ['multicolor', 'colourful', 'rang biranga', 'multi-color', 'rangin'],
    };

    String? color;
    for (final entry in colors.entries) {
      for (final kw in entry.value) {
        if (_containsWord(lower, kw)) {
          color = entry.key;
          break;
        }
      }
      if (color != null) break;
    }

    // 6. Size
    String? size;
    final sizeRegex = RegExp(r'(\d+(?:\.\d+)?\s*(?:inch|inches|cm|centimeters?|feet|foot|meter|in|ft)\b)');
    final sm = sizeRegex.firstMatch(lower);
    if (sm != null) {
      size = sm.group(1)!.trim();
    } else {
      if (_containsWord(lower, 'small') || _containsWord(lower, 'chhota') || _containsWord(lower, 'chhoti')) {
        size = 'Small';
      } else if (_containsWord(lower, 'medium') || _containsWord(lower, 'madhyam') || _containsWord(lower, 'beech ka')) {
        size = 'Medium';
      } else if (_containsWord(lower, 'large') || _containsWord(lower, 'bada') || _containsWord(lower, 'badi') || _containsWord(lower, 'big')) {
        size = 'Large';
      } else if (_containsWord(lower, 'extra large') || _containsWord(lower, 'xl')) {
        size = 'XL';
      }
    }

    // 7. Weight
    String? weight;
    final weightRegex = RegExp(r'(\d+(?:\.\d+)?\s*(?:gram|grams|gm|gms|g|kg|kilogram|kilo)\b)');
    final wm = weightRegex.firstMatch(lower);
    if (wm != null) {
      weight = wm.group(1)!.trim();
    } else if (lower.contains('aadha kilo') || lower.contains('aadha kg')) {
      weight = '500 g';
    } else if (lower.contains('ek kilo') || lower.contains('1 kilo')) {
      weight = '1 kg';
    }

    // 8. Quantity (Ready Stock)
    int? quantity;
    final qtyRegex = RegExp(r'(\d+)\s*(?:piece|pieces|pcs|pc|item|items|set)\b');
    final qm = qtyRegex.firstMatch(lower);
    if (qm != null) {
      quantity = int.tryParse(qm.group(1)!);
    } else if (lower.contains('single piece') || lower.contains('ek piece') || lower.contains('1 piece')) {
      quantity = 1;
    } else if (lower.contains('do piece') || lower.contains('pair') || lower.contains('joda')) {
      quantity = 2;
    }

    // 9. Production Capacity (Kitna bana sakte ho)
    String? productionCapacity;
    final capRegex = RegExp(r'(\d+)\s*(?:piece|pcs|item)?\s*(?:mahine|month|hafte|week|din|day)\s*(?:me|mein)?\s*(?:bana sakte|ban sakte|supply)');
    final capMatch = capRegex.firstMatch(lower);
    if (capMatch != null) {
      productionCapacity = '${capMatch.group(1)} pieces';
    } else if (lower.contains('50 piece') || lower.contains('50 bana')) {
      productionCapacity = '50 pieces per month';
    } else if (lower.contains('100 piece') || lower.contains('100 bana')) {
      productionCapacity = '100 pieces per month';
    }

    // 10. Making Time
    String? makingTime;
    final timeMap = [
      (RegExp(r'(\d+)\s*(?:din|days?)\b'), (Match m) => '${m.group(1)} days'),
      (RegExp(r'(\d+)\s*(?:hafte|hafta|weeks?)\b'), (Match m) => '${m.group(1)} weeks'),
      (RegExp(r'(\d+)\s*(?:mahine|mahina|months?)\b'), (Match m) => '${m.group(1)} months'),
      (RegExp(r'(\d+)\s*(?:ghante|ghanta|hours?)\b'), (Match m) => '${m.group(1)} hours'),
      (RegExp(r'\bek\s*din\b'), (Match _) => '1 day'),
      (RegExp(r'\bdo\s*din\b'), (Match _) => '2 days'),
      (RegExp(r'\bteen\s*din\b'), (Match _) => '3 days'),
      (RegExp(r'\bchar\s*din\b'), (Match _) => '4 days'),
      (RegExp(r'\bpanch\s*din\b'), (Match _) => '5 days'),
      (RegExp(r'\bek\s*hafta\b'), (Match _) => '1 week'),
      (RegExp(r'\bdo\s*hafte\b'), (Match _) => '2 weeks'),
    ];
    for (final pair in timeMap) {
      final m = pair.$1.firstMatch(lower);
      if (m != null) {
        makingTime = pair.$2(m);
        break;
      }
    }

    // 11. Making Process
    String? makingProcess;
    final processHints = <String>[];
    if (lower.contains('wheel') || lower.contains('chaak')) {
      processHints.add('Wheel-turned');
    }
    if (lower.contains('carv') || lower.contains('nakkashi')) {
      processHints.add('Hand-carved');
    }
    if (lower.contains('paint') || lower.contains('rang') || lower.contains('chitra')) {
      processHints.add('Hand-painted');
    }
    if (lower.contains('weave') || lower.contains('bunai') || lower.contains('handloom')) {
      processHints.add('Handloom woven');
    }
    if (lower.contains('mould') || lower.contains('dhalai')) {
      processHints.add('Molded and cured');
    }
    if (lower.contains('bhatti') || lower.contains('kiln') || lower.contains('pakate')) {
      processHints.add('Kiln-baked');
    }
    if (processHints.isEmpty) {
      if (lower.contains('hath se') || lower.contains('haath se') || lower.contains('handmade') || lower.contains('handcrafted')) {
        processHints.add('Completely hand-crafted by artisan');
      }
    }
    if (processHints.isNotEmpty) {
      makingProcess = processHints.join(', ');
    }

    // 12. Location
    final locations = [
      'Jaipur', 'Varanasi', 'Banaras', 'Lucknow', 'Jodhpur', 'Udaipur',
      'Kutch', 'Surat', 'Ahmedabad', 'Bhopal', 'Indore', 'Kashmir',
      'Srinagar', 'Bengal', 'Kolkata', 'Mysore', 'Bhubaneswar', 'Delhi',
      'Rajasthan', 'Gujarat', 'Uttar Pradesh', 'Madhya Pradesh', 'Odisha',
      'Assam', 'Bihar', 'Tamil Nadu', 'Kerala', 'Karnataka', 'Punjab'
    ];
    String? location;
    for (final loc in locations) {
      if (_containsWord(lower, loc.toLowerCase())) {
        location = loc;
        break;
      }
    }

    // 13. Product Name
    final nounMap = <String, List<String>>{
      'Decorative Pot': ['matka', 'pot', 'handi', 'ghada', 'kalash'],
      'Vase': ['vase', 'guldan', 'flower pot'],
      'Diya Set': ['diya', 'deepak', 'diye'],
      'Serving Plate': ['plate', 'thali', 'platter'],
      'Wall Hanging': ['wall hanging', 'jharokha', 'toran'],
      'Saree': ['saree', 'sari'],
      'Kurta': ['kurta', 'kurti'],
      'Shawl': ['shawl', 'dupatta', 'stole'],
      'Fruit Basket': ['basket', 'tokri'],
      'Wooden Box': ['box', 'dabba', 'sandook'],
      'Statue / Idol': ['statue', 'idol', 'murti', 'vigrah'],
      'Necklace': ['necklace', 'haar', 'chain'],
      'Earrings': ['earring', 'earrings', 'jhumka', 'jhumke'],
      'Painting': ['painting', 'chitra', 'portrait'],
      'Handbag': ['wallet', 'purse', 'bag', 'jhola'],
      'Pen Stand': ['pen stand', 'desk stand'],
      'Coasters': ['coaster', 'coasters'],
    };

    String? detectedNoun;
    for (final entry in nounMap.entries) {
      for (final kw in entry.value) {
        if (_containsWord(lower, kw)) {
          detectedNoun = entry.key;
          break;
        }
      }
      if (detectedNoun != null) break;
    }

    final nameParts = <String>[];
    if (location != null) nameParts.add(location);
    if (craft != null && craft != 'Handcrafted') {
      nameParts.add(craft);
    } else if (material != null) {
      nameParts.add(material);
    }

    if (detectedNoun != null) {
      nameParts.add(detectedNoun);
    } else if (category != null) {
      nameParts.add(category.split('&').first.trim());
    } else {
      nameParts.add('Handcrafted Craft');
    }

    final productName = nameParts.join(' ');

    // 14. Craft Story
    var craftStory = 'Authentic handcrafted ${detectedNoun ?? 'creation'} made by skilled artisan';
    if (location != null) craftStory += ' in $location';
    craftStory += '. ';
    if (material != null && craft != null) {
      craftStory += 'Created using traditional ${craft.toLowerCase()} techniques with premium ${material.toLowerCase()}. ';
    } else if (material != null) {
      craftStory += 'Crafted from high-quality ${material.toLowerCase()}. ';
    }
    if (makingTime != null) {
      craftStory += 'Takes approximately $makingTime of dedicated craftsmanship to complete.';
    }

    final artisanIntro = 'Dedicated handicraft artisan practicing traditional ${craft ?? 'heritage'} art in ${location ?? 'India'}.';

    return {
      'product_name': productName,
      'category': category,
      'material': material,
      'craft': craft,
      'color': color,
      'size': size,
      'weight': weight,
      'quantity': quantity,
      'production_capacity': productionCapacity,
      'making_time': makingTime,
      'making_process': makingProcess,
      'location': location,
      'price': price,
      'craft_story': craftStory,
      'artisan_intro': artisanIntro,
    };
  }

  static Map<String, dynamic> extractStep1(String transcript) {
    final full = extract(transcript);
    return {
      'product_name': full['product_name'],
      'category': full['category'],
      'material': full['material'],
      'craft': full['craft'],
      'color': full['color'],
      'size': full['size'],
      'weight': full['weight'],
    };
  }

  static Map<String, dynamic> extractStep2(String transcript) {
    final full = extract(transcript);
    return {
      'quantity': full['quantity'],
      'production_capacity': full['production_capacity'],
      'making_time': full['making_time'],
      'making_process': full['making_process'],
    };
  }

  static Map<String, dynamic> extractStep3(String transcript) {
    final full = extract(transcript);
    return {
      'craft_story': full['craft_story'],
      'location': full['location'],
      'artisan_intro': full['artisan_intro'],
    };
  }

  static bool _containsWord(String text, String word) {
    if (word.contains(' ')) {
      return text.contains(word);
    }
    return RegExp(r'\b' + RegExp.escape(word) + r'\b').hasMatch(text);
  }
}
