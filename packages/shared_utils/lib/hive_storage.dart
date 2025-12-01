import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_utils/hive_boxes.dart';

class HiveStorage {
  static final HiveStorage _instance = HiveStorage._internal();
  factory HiveStorage() => _instance;
  HiveStorage._internal();

  // ===== 默认 Box 与 Key 前缀 =====
  static const String _defaultBoxName = boxApp;
  static const String _collectionPrefix = kCol;
  static const String _objectPrefix = kObj;

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
    await box.deleteAll([key, _collectionPrefix + key, _objectPrefix + key]);
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

  // =========== 删除box=============
  Future<void> deleteBoxCompletely(String name) async {
    // 如果已打开，先关闭
    if (Hive.isBoxOpen(name)) {
      await Hive.box(name).close();
    }
    // 物理删除 box 文件
    await Hive.deleteBoxFromDisk(name);
  }

  // =============调试错误使用================

  // HiveStorage 内：putObject
  // Future<void> putObject<T>(String key, T? object, {String? boxName}) async {
  //   final box = await _safeBox(boxName ?? _defaultBoxName);
  //   final storeKey = _objectPrefix + key;

  //   // 诊断日志
  //   debugPrint('PUT-OBJ box=${box.name} key=$storeKey T=$T valueType=${object?.runtimeType}\n${StackTrace.current}');

  //   // 防呆：wallet/currentSelectWallet 只能写 Wallet
  //   if ((boxName ?? _defaultBoxName) == 'wallet' && key == 'currentSelectWallet') {
  //     if (object != null && object is! Wallet) {
  //       throw ArgumentError('currentSelectWallet 只能写 Wallet，传入的是 ${object.runtimeType}');
  //     }
  //   }

  //   if (object == null) {
  //     await box.delete(storeKey);
  //   } else {
  //     await box.put(storeKey, object);
  //   }
  // }

  // HiveStorage 内：putList
  // Future<void> putList<T>(String key, List<T> list, {String? boxName}) async {
  //   final box = await _safeBox(boxName ?? _defaultBoxName);
  //   final storeKey = _collectionPrefix + key;

  //   // 诊断日志
  //   final headType = list.isNotEmpty ? list.first.runtimeType : 'EMPTY';
  //   debugPrint('PUT-LIST box=${box.name} key=$storeKey T=$T elemType=$headType size=${list.length}\n${StackTrace.current}');

  //   if (list.isEmpty) {
  //     await box.delete(storeKey);
  //   } else {
  //     await box.put(storeKey, list);
  //   }
  // }

  // HiveStorage 内：getList
  // Future<List<T>?> getList<T>(String key, {String? boxName}) async {
  //   final box = await _safeBox(boxName ?? _defaultBoxName);
  //   final storeKey = _collectionPrefix + key;
  //   final list = await _get(box, storeKey);
  //   debugPrint('GET-LIST box=${box.name} storeKey=$storeKey -> $list');
  //   if (list is List) {
  //     // 元素类型校验，第一时间暴露“Wallet vs TransactionRecord”混放
  //     if (list.isNotEmpty && list.first is! T) {
  //       debugPrint('❌ TYPE MISMATCH getList<$T> from ${box.name}/$storeKey: elem0=${list.first.runtimeType}');
  //       throw StateError('getList<$T> 类型不匹配，实际是 ${list.first.runtimeType}');
  //     }
  //     return List<T>.from(list);
  //   }
  //   return null;
  // }

  // Future<BoxBase> _safeBox(String boxName, {bool lazy = false}) async {
  //   // 若缓存中有且已开，优先复用
  //   final existed = _opened[boxName];
  //   if (existed != null && existed.isOpen) return existed;

  //   if (existed != null && !existed.isOpen) {
  //     _opened.remove(boxName);
  //   }

  //   // 如果外部已打开，先拿到实例
  //   if (Hive.isBoxOpen(boxName)) {
  //     final b = Hive.box(boxName);
  //     // 👇 先做“探针写入”，看看这个实例是不是被锁成了某种泛型视图（比如 Box<Wallet>）
  //     final polluted = await _isBoxPolluted(b);
  //     if (polluted) {
  //       // 自动自愈：关闭该实例，下面我们按“无泛型视图”重新打开
  //       await b.close();
  //     } else {
  //       _opened[boxName] = b;
  //       debugPrint('[_safeBox] reuse opened "$boxName" (${b.runtimeType})');
  //       return b;
  //     }
  //   }

  //   // 统一用非泛型打开（transactions 建议 LazyBox）
  //   final useLazy = boxName == boxTx || lazy;

  //   BoxBase opened;
  //   if (useLazy) {
  //     opened = await Hive.openLazyBox(boxName);
  //   } else {
  //     opened = await Hive.openBox(boxName);
  //   }
  //   // 再探针一次，确保是干净的动态实例
  //   final polluted = await _isBoxPolluted(opened);
  //   if (polluted) {
  //     // 到这里仍然污染，直接删磁盘重建（只对 tx 这种缓存箱这么干，谨慎！）
  //     await opened.close();
  //     await Hive.deleteBoxFromDisk(boxName);
  //     opened = useLazy ? await Hive.openLazyBox(boxName) : await Hive.openBox(boxName);
  //     final ok = await _isBoxPolluted(opened) == false;
  //     debugPrint('[_safeBox] re-open "$boxName" after delete; clean=$ok');
  //   }

  //   _opened[boxName] = opened;
  //   debugPrint('[_safeBox] opened "$boxName" as ${opened.runtimeType}');
  //   return opened;
  // }

  // Future<bool> _isBoxPolluted(BoxBase b) async {
  //   try {
  //     if (b is Box) {
  //       await b.put('__probe__', '__ok__');
  //       await b.delete('__probe__');
  //     } else if (b is LazyBox) {
  //       await b.put('__probe__', '__ok__');
  //       await b.delete('__probe__');
  //     }
  //     return false;
  //   } catch (e, st) {
  //     debugPrint('🚨 Box "${b.name}" polluted: $e\n$st');
  //     return true;
  //   }
  // }
}
