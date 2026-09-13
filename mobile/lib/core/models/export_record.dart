import 'dart:convert';

class ExportRecord {
  final String id;
  final String marketplaceId;
  final String marketplaceName;
  final String fileName;
  final String filePath;
  final DateTime exportedAt;
  final int productCount;
  final String fileType;
  final int? fileSize;

  const ExportRecord({
    required this.id,
    required this.marketplaceId,
    required this.marketplaceName,
    required this.fileName,
    required this.filePath,
    required this.exportedAt,
    required this.productCount,
    this.fileType = 'XLSX',
    this.fileSize,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'marketplaceId': marketplaceId,
        'marketplaceName': marketplaceName,
        'fileName': fileName,
        'filePath': filePath,
        'exportedAt': exportedAt.toIso8601String(),
        'productCount': productCount,
        'fileType': fileType,
        'fileSize': fileSize,
      };

  factory ExportRecord.fromJson(Map<String, dynamic> json) => ExportRecord(
        id: json['id'] as String,
        marketplaceId: json['marketplaceId'] as String,
        marketplaceName: json['marketplaceName'] as String,
        fileName: json['fileName'] as String,
        filePath: json['filePath'] as String,
        exportedAt: DateTime.parse(json['exportedAt'] as String),
        productCount: json['productCount'] as int,
        fileType: json['fileType'] as String? ?? 'XLSX',
        fileSize: json['fileSize'] as int?,
      );

  static List<ExportRecord> listFromJson(String jsonString) {
    if (jsonString.isEmpty) return [];
    final List<dynamic> list = jsonDecode(jsonString);
    return list.map((e) => ExportRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJson(List<ExportRecord> records) {
    return jsonEncode(records.map((r) => r.toJson()).toList());
  }
}
