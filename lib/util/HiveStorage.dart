import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:untitled1/constants/hive_boxes.dart';

class HiveStorage {
  static final HiveStorage _instance = HiveStorage._internal();
  factory HiveStorage() => _instance;
  HiveStorage._internal();

  // ===== 默认 Box 与 Key 前缀 =====
  static const String _defaultBoxName = boxApp;
  static const String _collectionPrefix = kObj;
  static const String _objectPrefix = kCol;

  /// 已打开的 Box（含 Box 与 LazyBox）
  final Map<String, BoxBase> _opened = {};

  /// 初始化 Hive（仅做 init，不强制打开具体 Box）
  Future<void> init({List<TypeAdapter>? adapters}) async {
    await Hive.initFlutter();
    if (adapters != null) {
      for (final a in adapters) {
        if (!Hive.isAdapterRegistered(a.typeId)) {
          Hive.registerAdapter(a);
        }
      }
    }
    // 提前把默认箱子打开（可选）
    await _safeBox(_defaultBoxName);
    debugPrint('Hive 初始化完成，默认 Box: $_defaultBoxName');
  }

  // ============== Box 管理 ==============

  /// 获取已打开的 Box；如未打开则自动以 Box<dynamic> 方式打开
  Future<BoxBase> _safeBox(String boxName, {bool lazy = false}) async {
    final existed = _opened[boxName];
    if (existed != null && existed.isOpen) return existed;

    // 已有但已关闭，移除缓存
    if (existed != null && !existed.isOpen) {
      _opened.remove(boxName);
    }

    // 若外部已经以某种类型打开了（例如别处先 open），直接取用
    if (Hive.isBoxOpen(boxName)) {
      final b = Hive.box(boxName);
      _opened[boxName] = b;
      return b;
    }

    // 按需懒打开
    BoxBase b;
    if (lazy) {
      b = await Hive.openLazyBox(boxName);
    } else {
      b = await Hive.openBox(boxName);
    }
    _opened[boxName] = b;
    return b;
  }

  /// 主动打开一个 Box（可选），用于你计划存大表时指定 lazy
  Future<void> ensureOpen(String boxName, {bool lazy = false}) async {
    await _safeBox(boxName, lazy: lazy);
  }

  // ============== 基础类型存储 ==============

  Future<void> putValue<T>(String key, T value, {String? boxName}) async {
    final box = await _safeBox(boxName ?? _defaultBoxName);
    if (box is Box) {
      await box.put(key, value);
    } else if (box is LazyBox) {
      await box.put(key, value);
    }
  }

  Future<T?> getValue<T>(String key, {String? boxName, T? defaultValue}) async {
    final box = await _safeBox(boxName ?? _defaultBoxName);
    final v = (box is Box) ? (box as Box).get(key, defaultValue: defaultValue) : await (box as LazyBox).get(key);
    return v is T ? v : defaultValue;
  }

  // ============== 对象存储（带 obj_ 前缀） ==============

  Future<void> putObject<T>(String key, T? object, {String? boxName}) async {
    final box = await _safeBox(boxName ?? _defaultBoxName);
    final storeKey = _objectPrefix + key;
    if (object == null) {
      await box.delete(storeKey);
    } else {
      await box.put(storeKey, object);
    }
  }

  Future<T?> getObject<T>(String key, {String? boxName}) async {
    final box = await _safeBox(boxName ?? _defaultBoxName);
    final storeKey = _objectPrefix + key;
    final raw = await _get(box, storeKey);
    if (raw == null) return null;
    if (raw is! T) {
      debugPrint('❌ 类型不匹配 getObject<$T>("$key"): 实际是 ${raw.runtimeType} (box=${box.name})');
      return null;
    }
    return raw as T;
  }

  // ============== 集合存储（带 col_ 前缀） ==============

  Future<void> putList<T>(String key, List<T> list, {String? boxName}) async {
    final box = await _safeBox(boxName ?? _defaultBoxName);
    final storeKey = _collectionPrefix + key;
    if (list.isEmpty) {
      await box.delete(storeKey);
    } else {
      await box.put(storeKey, list);
    }
  }

  Future<List<T>?> getList<T>(String key, {String? boxName}) async {
    final box = await _safeBox(boxName ?? _defaultBoxName);
    final storeKey = _collectionPrefix + key;
    final list = await _get(box, storeKey);
    return list is List ? List<T>.from(list) : null;
  }

  Future<void> putMap<K, V>(String key, Map<K, V> map, {String? boxName}) async {
    final box = await _safeBox(boxName ?? _defaultBoxName);
    final storeKey = _collectionPrefix + key;
    if (map.isEmpty) {
      await box.delete(storeKey);
    } else {
      await box.put(storeKey, map);
    }
  }

  Future<Map<K, V>?> getMap<K, V>(String key, {String? boxName}) async {
    final box = await _safeBox(boxName ?? _defaultBoxName);
    final storeKey = _collectionPrefix + key;
    final map = await _get(box, storeKey);
    return map is Map ? Map<K, V>.from(map) : null;
  }

  // ============== 其他操作 ==============

  Future<void> delete(String key, {String? boxName}) async {
    final box = await _safeBox(boxName ?? _defaultBoxName);
    await box.delete(key);
    await box.delete(_collectionPrefix + key);
    await box.delete(_objectPrefix + key);
  }

  Future<void> clear({String? boxName}) async {
    final b = await _safeBox(boxName ?? _defaultBoxName);
    await b.clear();
  }

  Future<bool> containsKey(String key, {String? boxName}) async {
    final box = await _safeBox(boxName ?? _defaultBoxName);
    return await box.containsKey(key) || await box.containsKey(_collectionPrefix + key) || await box.containsKey(_objectPrefix + key);
  }

  Future<BoxBase> getBox({String? boxName}) async {
    return _safeBox(boxName ?? _defaultBoxName);
  }

  // ====== 调试工具 ======
  bool _verbose = true;
  void _log(String msg) {
    if (_verbose) debugPrint('🟣[HiveStorage] $msg');
  }

  Future<void> debugDump({String? boxName}) async {
    final box = await _safeBox(boxName ?? _defaultBoxName);
    _log('===== DUMP (${box.name}) =====');
    if (box is Box) {
      for (final k in box.keys) {
        final v = box.get(k);
        _log('key: $k -> type: ${v.runtimeType}');
      }
    } else if (box is LazyBox) {
      _log('LazyBox 不支持直接遍历 values，建议自建索引键。');
    }
  }

  // ============== 私有小工具 ==============

  Future _get(BoxBase box, String key) async {
    if (box is Box) return box.get(key);
    return (box as LazyBox).get(key);
  }
}
