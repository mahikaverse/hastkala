/// Curated, HTTP-verified Unsplash image URLs used as universal fallbacks so
/// the app never shows an empty/blank image anywhere.
const List<String> kUnsplashFallbackPhotos = [
  'photo-1610701596007-11502861dcfa',
  'photo-1565193566173-7a0ee3dbe261',
  'photo-1610030469983-98e550d6193c',
  'photo-1578749556568-bc2c40e68b61',
  'photo-1590422749897-47036da0b0ff',
  'photo-1602751584552-8ba73aad10e1',
  'photo-1528459801416-a9e53bbf4e17',
  'photo-1524292332709-b33366a7f165',
  'photo-1606760227091-3dd870d97f1d',
  'photo-1617038220319-276d3cfab638',
  'photo-1600003014755-ba31aa59c4b6',
  'photo-1493106641515-6b5631de4bb9',
  'photo-1584589167171-541ce45f1eea',
  'photo-1544967082-d9d25d867d66',
  'photo-1573408301185-9146fe634ad0',
  'photo-1601121141461-9d6647bca1ed',
  'photo-1591561954557-26941169b49e',
  'photo-1609139003551-ee40f5f73ec0',
  'photo-1611591437281-460bfbe1220a',
  'photo-1567538096630-e0c55bd6374c',
  'photo-1519710164239-da123dc03ef4',
  'photo-1531835551805-16d864c8d311',
  'photo-1493663284031-b7e3aefcae8e',
  'photo-1513519245088-0e12902e5a38',
  'photo-1608042314453-ae338d80c427',
  'photo-1620656798579-1984d9e87df7',
  'photo-1596461404969-9ae70f2830c1',
  'photo-1620733723572-11c53f73a416',
  'photo-1594736797933-d0501ba2fe65',
  'photo-1600166898405-da9535204843',
  'photo-1615529182904-14819c35db37',
  'photo-1556228720-195a672e8a03',
  'photo-1549488344-1f9b8d2bd1f3',
  'photo-1567696911980-2eed69a46042',
  'photo-1591195853828-11db59a44f6b',
  'photo-1594040226829-7f251ab46d80',
  'photo-1526047932273-341f2a7631f9',
];

/// Category-specific Unsplash fallbacks (verified 200 OK).
const Map<String, List<String>> kUnsplashByCategory = {
  'Pottery & Ceramics': [
    'photo-1610701596007-11502861dcfa',
    'photo-1565193566173-7a0ee3dbe261',
    'photo-1610030469983-98e550d6193c',
    'photo-1578749556568-bc2c40e68b61',
  ],
  'Blue Pottery': [
    'photo-1610701596007-11502861dcfa',
    'photo-1565193566173-7a0ee3dbe261',
    'photo-1610030469983-98e550d6193c',
  ],
  'Terracotta': [
    'photo-1567538096630-e0c55bd6374c',
    'photo-1519710164239-da123dc03ef4',
    'photo-1531835551805-16d864c8d311',
  ],
  'Textiles': [
    'photo-1528459801416-a9e53bbf4e17',
    'photo-1524292332709-b33366a7f165',
  ],
  'Handloom Textiles': [
    'photo-1528459801416-a9e53bbf4e17',
    'photo-1524292332709-b33366a7f165',
    'photo-1606760227091-3dd870d97f1d',
  ],
  'Embroidery': [
    'photo-1591561954557-26941169b49e',
    'photo-1609139003551-ee40f5f73ec0',
    'photo-1611591437281-460bfbe1220a',
  ],
  'Madhubani Paintings': [
    'photo-1493106641515-6b5631de4bb9',
    'photo-1584589167171-541ce45f1eea',
    'photo-1544967082-d9d25d867d66',
  ],
  'Paintings & Art': [
    'photo-1493106641515-6b5631de4bb9',
    'photo-1584589167171-541ce45f1eea',
  ],
  'Wood & Carving': [
    'photo-1513519245088-0e12902e5a38',
    'photo-1608042314453-ae338d80c427',
  ],
  'Wooden Crafts': [
    'photo-1513519245088-0e12902e5a38',
    'photo-1608042314453-ae338d80c427',
    'photo-1620656798579-1984d9e87df7',
  ],
  'Jewellery': [
    'photo-1620733723572-11c53f73a416',
    'photo-1594736797933-d0501ba2fe65',
  ],
  'Handmade Jewellery': [
    'photo-1620733723572-11c53f73a416',
    'photo-1594736797933-d0501ba2fe65',
    'photo-1600166898405-da9535204843',
  ],
  'Bamboo & Cane': [
    'photo-1549488344-1f9b8d2bd1f3',
    'photo-1567696911980-2eed69a46042',
    'photo-1591195853828-11db59a44f6b',
  ],
  'Home Decor': [
    'photo-1513519245088-0e12902e5a38',
    'photo-1493663284031-b7e3aefcae8e',
    'photo-1601121141461-9d6647bca1ed',
  ],
  'Kitchen & Dining': [
    'photo-1590422749897-47036da0b0ff',
    'photo-1602751584552-8ba73aad10e1',
  ],
};

int _stableSeed(String value) {
  var h = 0;
  for (final r in value.runes) {
    h = (h * 31 + r) & 0x7fffffff;
  }
  return h;
}

/// Returns a verified Unsplash image URL chosen deterministically from [seed]
/// (and [category] when provided) so the same product always gets the same
/// fallback image.
String unsplashFallbackUrl({String seed = 'hastkala', String? category}) {
  final cat = category?.trim();
  if (cat != null && cat.isNotEmpty) {
    final list = kUnsplashByCategory[cat];
    if (list != null && list.isNotEmpty) {
      return 'https://images.unsplash.com/${list[_stableSeed(seed) % list.length]}?w=800&h=800&fit=crop';
    }
  }
  return 'https://images.unsplash.com/${kUnsplashFallbackPhotos[_stableSeed(seed) % kUnsplashFallbackPhotos.length]}?w=800&h=800&fit=crop';
}
