import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:untitled1/hive/Wallet.dart' as Mywallet;
import 'package:untitled1/hive/transaction_record.dart';

class HiveStorage {
  static final HiveStorage _instance = HiveStorage._internal();
  factory HiveStorage() => _instance;
  HiveStorage._internal();

  static const String _defaultBoxName = 'appData';
  static const String _collectionPrefix = 'col_';
  static const String _objectPrefix = 'obj_';

  /// 保存 Box 实例，避免重复打开
  Box? _box;

  /// 初始化 Hive
  Future<void> init({List<TypeAdapter>? adapters}) async {
    await Hive.initFlutter();
    // final box = await HiveStorage().getBox();

    // 注册类型适配器
    if (adapters != null) {
      for (final adapter in adapters) {
        if (!Hive.isAdapterRegistered(adapter.typeId)) {
          Hive.registerAdapter(adapter);
        }
      }
    }

    _box = await Hive.openBox(_defaultBoxName);
    debugPrint('Hive box 初始化完成: $_defaultBoxName');
    // final v = box.get('obj_currentSelectWallet');
    // debugPrint('obj_currentSelectWallet runtimeType: ${v?.runtimeType}');
  }

  /// 确保 Box 已准备好（懒加载机制）
  Future<void> ensureBoxReady() async {
    if (_box != null && _box!.isOpen) return;
    if (!Hive.isBoxOpen(_defaultBoxName)) {
      _box = await Hive.openBox(_defaultBoxName);
      debugPrint('📦 Hive box 已重新打开: $_defaultBoxName');
    }
  }

  /// 自动返回已准备好的 Box（防止并发未初始化）
  Future<Box> get _safeBox async {
    await ensureBoxReady();

    // 再检查一次
    if (_box == null || !_box!.isOpen) {
      debugPrint('Hive box 仍为空或未打开，尝试重新初始化 HiveStorage');
      try {
        await init();
      } catch (e) {
        debugPrint('Hive init 异常: $e');
        await Hive.deleteBoxFromDisk(_defaultBoxName);
        await init();
      }
    }

    if (_box == null) {
      throw HiveError('Hive 仍未初始化成功，请检查初始化流程');
    }

    return _box!;
  }

  // ================== 基础类型存储 ================== //

  Future<void> putValue<T>(String key, T value) async {
    final box = await _safeBox;
    await box.put(key, value);
  }

  Future<T?> getValue<T>(String key, {T? defaultValue}) async {
    final box = await _safeBox;
    final value = box.get(key, defaultValue: defaultValue);
    return value is T ? value : defaultValue;
  }

  // ================== 对象存储 ================== //

  Future<void> putObject<T>(String key, T? object) async {
    final box = await _safeBox;
    if (object == null) {
      await box.delete(_objectPrefix + key);
    } else {
      await box.put(_objectPrefix + key, object);
    }
  }

  Future<T?> getObject<T>(String key) async {
    final box = await _safeBox;
    final storeKey = _objectPrefix + key;
    final raw = box.get(storeKey);

    // 打印调用来源（前 8 行栈）
    final st = StackTrace.current.toString().split('\n').take(8).join('\n');
    debugPrint('[HiveStorage] getObject<$T> key="$key" storeKey="$storeKey" -> ${raw?.runtimeType}\nCALLER:\n$st');

    // Wallet 读取白名单：只允许 currentSelectWallet
    if (T.toString().endsWith('Wallet') && key != 'currentSelectWallet') {
      debugPrint('❌ 非法读取：getObject<Wallet>("$key")，只允许读取 "currentSelectWallet"');
      // 返回 null，避免业务直接崩；你也可以改成 throw
      return null;
    }

    if (raw == null) return null;
    if (raw is! T) {
      debugPrint('❌ 类型不匹配 getObject<$T>("$key"): 实际是 ${raw.runtimeType} (storeKey=$storeKey)');
      // 返回 null 避免业务层直接崩
      return null;
    }
    return raw as T;
  }

  // ================== 集合存储 ================== //

  Future<void> putList<T>(String key, List<T> list) async {
    final box = await _safeBox;
    if (list.isEmpty) {
      await box.delete(_collectionPrefix + key);
    } else {
      await box.put(_collectionPrefix + key, list);
    }
  }

  Future<List<T>?> getList<T>(String key) async {
    final box = await _safeBox;
    final list = box.get(_collectionPrefix + key);
    return list is List ? List<T>.from(list) : null;
  }

  Future<void> putMap<K, V>(String key, Map<K, V> map) async {
    final box = await _safeBox;
    if (map.isEmpty) {
      await box.delete(_collectionPrefix + key);
    } else {
      await box.put(_collectionPrefix + key, map);
    }
  }

  Future<Map<K, V>?> getMap<K, V>(String key) async {
    final box = await _safeBox;
    final map = box.get(_collectionPrefix + key);
    return map is Map ? Map<K, V>.from(map) : null;
  }

  // ================== 其他操作 ================== //

  Future<void> delete(String key) async {
    final box = await _safeBox;
    await box.delete(key);
    await box.delete(_collectionPrefix + key);
    await box.delete(_objectPrefix + key);
  }

  Future<void> clear() async {
    final box = await _safeBox;
    await box.clear();
  }

  bool containsKey(String key) {
    return _box?.containsKey(key) == true || _box?.containsKey(_collectionPrefix + key) == true || _box?.containsKey(_objectPrefix + key) == true;
  }

  Future<Box> getBox() async {
    return await _safeBox;
  }

  // ====== 调试工具 ======
  bool _verbose = true; // 临时打开详细日志

  void _log(String msg) {
    if (_verbose) debugPrint('🟣[HiveStorage] $msg');
  }

  /// 打印当前 box 所有键和值类型
  Future<void> debugDump() async {
    final box = await _safeBox;
    _log('===== DUMP (${box.name}) =====');
    for (final k in box.keys) {
      final v = box.get(k);
      _log('key: $k -> type: ${v.runtimeType}');
    }
  }
}
