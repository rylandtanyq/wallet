import 'package:hive_flutter/hive_flutter.dart';

class HiveStorage {
  static final HiveStorage _instance = HiveStorage._internal();
  factory HiveStorage() => _instance;
  HiveStorage._internal();

  static const String _defaultBoxName = 'appData';
  static const String _collectionPrefix = 'col_';
  static const String _objectPrefix = 'obj_';

  /// 初始化Hive
  Future<void> init({List<TypeAdapter>? adapters}) async {
    await Hive.initFlutter();

    // 注册类型适配器
    if (adapters != null) {
      for (final adapter in adapters) {
        if (!Hive.isAdapterRegistered(adapter.typeId)) {
          Hive.registerAdapter(adapter);
        }
      }
    }

    await Hive.openBox(_defaultBoxName);
  }

  /// 获取存储盒子
  Box<dynamic> _getBox() => Hive.box(_defaultBoxName);

  // ================== 基础类型存储 ================== //

  Future<void> putValue<T>(String key, T value) async {
    await _getBox().put(key, value);
  }

  T? getValue<T>(String key, {T? defaultValue}) {
    final value = _getBox().get(key, defaultValue: defaultValue);
    return value is T ? value : defaultValue;
  }

  // ================== 对象存储 ================== //

  Future<void> putObject<T>(String key, T object) async {
    if (object == null) {
      await _getBox().delete(_objectPrefix + key);
      return;
    }

    await _getBox().put(_objectPrefix + key, object);
  }

  T? getObject<T>(String key) {
    return _getBox().get(_objectPrefix + key) as T?;
  }

  // ================== 集合存储 ================== //

  Future<void> putList<T>(String key, List<T> list) async {
    if (list.isEmpty) {
      await _getBox().delete(_collectionPrefix + key);
      return;
    }

    await _getBox().put(_collectionPrefix + key, list);
  }

  List<T>? getList<T>(String key) {
    final list = _getBox().get(_collectionPrefix + key);
    return list is List ? List<T>.from(list) : null;
  }

  Future<void> putMap<K, V>(String key, Map<K, V> map) async {
    if (map.isEmpty) {
      await _getBox().delete(_collectionPrefix + key);
      return;
    }

    await _getBox().put(_collectionPrefix + key, map);
  }

  Map<K, V>? getMap<K, V>(String key) {
    final map = _getBox().get(_collectionPrefix + key);
    return map is Map ? Map<K, V>.from(map) : null;
  }

  // ================== 其他操作 ================== //

  Future<void> delete(String key) async {
    await _getBox().delete(key);
    await _getBox().delete(_collectionPrefix + key);
    await _getBox().delete(_objectPrefix + key);
  }

  Future<void> clear() async {
    await _getBox().clear();
  }

  bool containsKey(String key) {
    return _getBox().containsKey(key) || _getBox().containsKey(_collectionPrefix + key) || _getBox().containsKey(_objectPrefix + key);
  }

  Future<void> ensureBoxReady([String boxName = _defaultBoxName]) async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }
}
