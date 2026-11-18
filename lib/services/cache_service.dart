import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local persistent cache service for map nodes & offline performance
class MapCacheService {
  static const String _mapNodesKey = 'cached_map_nodes_v1';

  /// Save map nodes list to SharedPreferences
  static Future<void> saveMapNodes(List<Map<String, dynamic>> nodes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonStr = jsonEncode(nodes);
      await prefs.setString(_mapNodesKey, jsonStr);
    } catch (_) {}
  }

  /// Get cached map nodes list from SharedPreferences
  static Future<List<Map<String, dynamic>>> getCachedMapNodes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_mapNodesKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final dynamic raw = jsonDecode(jsonStr);
        if (raw is List) {
          return List<Map<String, dynamic>>.from(raw);
        }
      }
    } catch (_) {}
    return [];
  }

  /// Clear map nodes cache
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_mapNodesKey);
    } catch (_) {}
  }
}
