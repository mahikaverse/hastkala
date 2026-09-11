/// Ultra-fast on-device catalog extractor for numeric/factual data only.
/// This extracts: price, material, size, weight, quantity, making_time, location, color.
/// It does NOT generate: product_name, craft, craft_story, artisan_intro, description.
/// Those must come from the LLM backend.
class FastCatalogExtractor {
  static Map<String, dynamic> extract(String transcript) {
    final t = transcript.trim();
    if (t.isEmpty) {
      return _emptyResult();
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

    // 2. Material — only when explicitly mentioned
    final materials = <String, List<String>>{
      'Terracotta': ['terracotta', 'teracota', 'pakki mitti', 'baked clay'],
      'Clay': ['clay', 'mitti', 'chikni mitti', 'kali mitti', 'lal mitti'],
      'Bamboo': ['bamboo', 'baans', 'bans', 'cane'],
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

    // 3. Color — only when explicitly mentioned
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

    // 4. Size
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

    // 5. Weight
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

    // 6. Quantity (Ready Stock)
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

    // 7. Production Capacity
    String? productionCapacity;
    final capRegex = RegExp(r'(\d+)\s*(?:piece|pcs|item)?\s*(?:mahine|month|hafte|week|din|day)\s*(?:me|mein)?\s*(?:bana sakte|ban sakte|supply)');
    final capMatch = capRegex.firstMatch(lower);
    if (capMatch != null) {
      productionCapacity = '${capMatch.group(1)} pieces';
    }

    // 8. Making Time
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

    // 9. Making Process — only if explicitly described
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
    if (processHints.isNotEmpty) {
      makingProcess = processHints.join(', ');
    }

    // 10. Location — only when explicitly mentioned
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

    // Return ONLY factual data. No product_name, no craft, no stories.
    return {
      'product_name': null,
      'category': null,
      'material': material,
      'craft': null,
      'color': color,
      'size': size,
      'weight': weight,
      'quantity': quantity,
      'production_capacity': productionCapacity,
      'making_time': makingTime,
      'making_process': makingProcess,
      'location': location,
      'price': price,
      'description': null,
      'craft_story': null,
      'artisan_intro': null,
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
      'description': full['description'],
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

  static Map<String, dynamic> _emptyResult() {
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
      'description': null,
      'craft_story': null,
      'artisan_intro': null,
    };
  }
}
