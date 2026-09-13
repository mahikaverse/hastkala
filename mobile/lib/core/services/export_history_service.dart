import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/export_record.dart';

class ExportHistoryService {
  static final ExportHistoryService _instance = ExportHistoryService._internal();
  factory ExportHistoryService() => _instance;
  ExportHistoryService._internal();

  static const String _storageKey = 'hastkala_export_history';
  static const int _maxRecords = 20;

  List<ExportRecord> _records = [];

  List<ExportRecord> get records => List.unmodifiable(_records);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey) ?? '';
    _records = ExportRecord.listFromJson(jsonString);

    _records.removeWhere((r) {
      final file = File(r.filePath);
      return !file.existsSync();
    });

    if (_records.length > _maxRecords) {
      _records = _records.sublist(0, _maxRecords);
      await _persist();
    }
  }

  Future<void> saveExport(ExportRecord record) async {
    _records.insert(0, record);

    if (_records.length > _maxRecords) {
      final removed = _records.sublist(_maxRecords);
      _records = _records.sublist(0, _maxRecords);
      for (final r in removed) {
        final file = File(r.filePath);
        if (file.existsSync()) {
          await file.delete();
        }
      }
    }

    await _persist();
  }

  Future<void> deleteExport(String id) async {
    final index = _records.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final record = _records[index];
    final file = File(record.filePath);
    if (file.existsSync()) {
      await file.delete();
    }

    _records.removeAt(index);
    await _persist();
  }

  Future<void> clearExports() async {
    for (final r in _records) {
      final file = File(r.filePath);
      if (file.existsSync()) {
        await file.delete();
      }
    }
    _records.clear();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, ExportRecord.listToJson(_records));
  }
}
