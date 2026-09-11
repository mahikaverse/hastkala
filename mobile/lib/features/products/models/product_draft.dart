class ProductDraft {
  String? imagePath;
  bool useEnhanced;
  String voiceTranscript;
  String? productName;
  String? category;
  String? material;
  String? craft;
  String? color;
  String? size;
  String? weight;
  int? quantity;
  String? makingTime;
  String? makingProcess;
  String? location;
  String? craftStory;
  int? price;
  int? expectedPrice;
  int? suggestedPrice;
  int? marketMin;
  int? marketMax;
  int? recommendedMin;
  int? recommendedMax;
  String? priceReason;
  int? comparablesFound;
  List<dynamic>? priceSources;
  String? artisanName;
  String? artisanCraft;
  String? artisanLocation;
  String? artisanIntro;

  ProductDraft({
    this.imagePath,
    this.useEnhanced = false,
    this.voiceTranscript = '',
    this.productName,
    this.category,
    this.material,
    this.craft,
    this.color,
    this.size,
    this.weight,
    this.quantity,
    this.makingTime,
    this.makingProcess,
    this.location,
    this.craftStory,
    this.price,
    this.expectedPrice,
    this.suggestedPrice,
    this.marketMin,
    this.marketMax,
    this.recommendedMin,
    this.recommendedMax,
    this.priceReason,
    this.comparablesFound,
    this.priceSources,
    this.artisanName,
    this.artisanCraft,
    this.artisanLocation,
    this.artisanIntro,
  });

  bool get isBase64Image => imagePath != null && imagePath!.startsWith('data:');
}
