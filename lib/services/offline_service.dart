import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  bool _isOnline = true;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  final List<OfflineAction> _pendingActions = [];
  
  // Getters
  bool get isOnline => _isOnline;
  List<OfflineAction> get pendingActions => List.unmodifiable(_pendingActions);

  Future<void> initialize() async {
    // Check initial connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;
    
    // Listen for connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      _isOnline = result != ConnectivityResult.none;
      if (_isOnline) {
        _syncPendingActions();
      }
    });
    
    // Load pending actions from storage
    await _loadPendingActions();
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
  }

  // Check if online
  bool checkConnectivity() {
    return _isOnline;
  }

  // Save data locally when offline
  Future<void> saveDataLocally(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, json.encode(data));
    } catch (e) {
      print('Error saving data locally: $e');
    }
  }

  // Get data from local storage
  Future<Map<String, dynamic>?> getLocalData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataString = prefs.getString(key);
      if (dataString != null) {
        return json.decode(dataString);
      }
    } catch (e) {
      print('Error getting local data: $e');
    }
    return null;
  }

  // Cache resources for offline use
  Future<void> cacheResource(String url, String content) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/offline_cache/${_getFileName(url)}');
      
      // Create directory if it doesn't exist
      await file.parent.create(recursive: true);
      
      // Save content
      await file.writeAsString(content);
      
      // Save cache metadata
      await saveDataLocally('cache_${_getFileName(url)}', {
        'url': url,
        'cachedAt': DateTime.now().toIso8601String(),
        'filePath': file.path,
      });
    } catch (e) {
      print('Error caching resource: $e');
    }
  }

  // Get cached resource
  Future<String?> getCachedResource(String url) async {
    try {
      final fileName = _getFileName(url);
      final metadata = await getLocalData('cache_$fileName');
      
      if (metadata != null) {
        final file = File(metadata['filePath']);
        if (await file.exists()) {
          return await file.readAsString();
        }
      }
    } catch (e) {
      print('Error getting cached resource: $e');
    }
    return null;
  }

  // Add offline action to queue
  Future<void> addOfflineAction(OfflineAction action) async {
    _pendingActions.add(action);
    await _savePendingActions();
    
    if (_isOnline) {
      await _syncPendingActions();
    }
  }

  // Sync pending actions when online
  Future<void> _syncPendingActions() async {
    if (!_isOnline || _pendingActions.isEmpty) return;
    
    final actionsToSync = List<OfflineAction>.from(_pendingActions);
    
    for (final action in actionsToSync) {
      try {
        final success = await _executeAction(action);
        if (success) {
          _pendingActions.remove(action);
        }
      } catch (e) {
        print('Error syncing action: $e');
      }
    }
    
    await _savePendingActions();
  }

  // Execute individual action
  Future<bool> _executeAction(OfflineAction action) async {
    try {
      switch (action.type) {
        case OfflineActionType.syncProgress:
          return await _syncProgress(action.data);
        case OfflineActionType.uploadStats:
          return await _uploadStats(action.data);
        case OfflineActionType.saveAchievement:
          return await _saveAchievement(action.data);
        case OfflineActionType.downloadResource:
          return await _downloadResource(action.data);
      }
    } catch (e) {
      print('Error executing action: $e');
      return false;
    }
    return false;
  }

  Future<bool> _syncProgress(Map<String, dynamic> data) async {
    // Simulate API call
    final response = await http.post(
      Uri.parse('https://api.example.com/sync/progress'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    return response.statusCode == 200;
  }

  Future<bool> _uploadStats(Map<String, dynamic> data) async {
    // Simulate API call
    final response = await http.post(
      Uri.parse('https://api.example.com/stats/upload'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    return response.statusCode == 200;
  }

  Future<bool> _saveAchievement(Map<String, dynamic> data) async {
    // Simulate API call
    final response = await http.post(
      Uri.parse('https://api.example.com/achievements/save'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    return response.statusCode == 200;
  }

  Future<bool> _downloadResource(Map<String, dynamic> data) async {
    final url = data['url'] as String;
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      await cacheResource(url, response.body);
      return true;
    }
    
    return false;
  }

  // Save and load pending actions
  Future<void> _savePendingActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final actionsJson = _pendingActions.map((a) => json.encode(a.toJson())).toList();
      await prefs.setStringList('pending_actions', actionsJson);
    } catch (e) {
      print('Error saving pending actions: $e');
    }
  }

  Future<void> _loadPendingActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final actionsJson = prefs.getStringList('pending_actions') ?? [];
      
      _pendingActions.clear();
      for (final actionJson in actionsJson) {
        final action = OfflineAction.fromJson(json.decode(actionJson));
        _pendingActions.add(action);
      }
    } catch (e) {
      print('Error loading pending actions: $e');
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/offline_cache');
      
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
      
      // Clear cache metadata
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('cache_')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Get cache size
  Future<int> getCacheSize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/offline_cache');
      
      if (!await cacheDir.exists()) return 0;
      
      int totalSize = 0;
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      print('Error getting cache size: $e');
      return 0;
    }
  }

  // Helper methods
  String _getFileName(String url) {
    return url.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  }

  // Download study materials for offline use
  Future<void> downloadStudyMaterials() async {
    final materials = [
      'https://example.com/ielts-vocabulary.json',
      'https://example.com/sat-math-formulas.json',
      'https://example.com/reading-passages.json',
      'https://example.com/writing-prompts.json',
    ];

    for (final material in materials) {
      if (!_isOnline) continue;
      
      final action = OfflineAction(
        type: OfflineActionType.downloadResource,
        data: {'url': material},
        timestamp: DateTime.now(),
      );
      
      await addOfflineAction(action);
    }
  }

  // Sync all local data when online
  Future<void> syncAllData() async {
    if (!_isOnline) return;
    
    // Sync progress
    await addOfflineAction(OfflineAction(
      type: OfflineActionType.syncProgress,
      data: {'timestamp': DateTime.now().toIso8601String()},
      timestamp: DateTime.now(),
    ));
    
    // Upload stats
    await addOfflineAction(OfflineAction(
      type: OfflineActionType.uploadStats,
      data: {'timestamp': DateTime.now().toIso8601String()},
      timestamp: DateTime.now(),
    ));
  }
}

enum OfflineActionType {
  syncProgress,
  uploadStats,
  saveAchievement,
  downloadResource,
}

class OfflineAction {
  final OfflineActionType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  OfflineAction({
    required this.type,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory OfflineAction.fromJson(Map<String, dynamic> json) {
    return OfflineAction(
      type: OfflineActionType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
