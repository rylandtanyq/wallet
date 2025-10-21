// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:flutter/foundation.dart';

// class HiveStorage {
//   static final HiveStorage _instance = HiveStorage._internal();
//   factory HiveStorage() => _instance;
//   HiveStorage._internal();

//   static const String _defaultBoxName = 'appData';
//   static const String _collectionPrefix = 'col_';
//   static const String _objectPrefix = 'obj_';

//   /// 保存 Box 实例，避免重复打开
//   Box? _box;

//   /// 初始化 Hive
//   Future<void> init({List<TypeAdapter>? adapters}) async {
//     await Hive.initFlutter();

//     // 注册类型适配器
//     if (adapters != null) {
//       for (final adapter in adapters) {
//         if (!Hive.isAdapterRegistered(adapter.typeId)) {
//           Hive.registerAdapter(adapter);
//         }
//       }
//     }

//     _box = await Hive.openBox(_defaultBoxName);
//     debugPrint('Hive box 初始化完成: $_defaultBoxName');
//   }

//   /// 确保 Box 已准备好（懒加载机制）
//   Future<void> ensureBoxReady() async {
//     if (_box != null && _box!.isOpen) return;
//     if (!Hive.isBoxOpen(_defaultBoxName)) {
//       _box = await Hive.openBox(_defaultBoxName);
//       debugPrint('📦 Hive box 已重新打开: $_defaultBoxName');
//     }
//   }

//   /// 自动返回已准备好的 Box（防止并发未初始化）
//   Future<Box> get _safeBox async {
//     await ensureBoxReady();

//     // 再检查一次
//     if (_box == null || !_box!.isOpen) {
//       debugPrint('Hive box 仍为空或未打开，尝试重新初始化 HiveStorage');
//       try {
//         await init();
//       } catch (e) {
//         debugPrint('Hive init 异常: $e');
//         await Hive.deleteBoxFromDisk(_defaultBoxName);
//         await init();
//       }
//     }

//     if (_box == null) {
//       throw HiveError('Hive 仍未初始化成功，请检查初始化流程');
//     }

//     return _box!;
//   }

//   // ================== 基础类型存储 ================== //

//   Future<void> putValue<T>(String key, T value) async {
//     final box = await _safeBox;
//     await box.put(key, value);
//   }

//   Future<T?> getValue<T>(String key, {T? defaultValue}) async {
//     final box = await _safeBox;
//     final value = box.get(key, defaultValue: defaultValue);
//     return value is T ? value : defaultValue;
//   }

//   // ================== 对象存储 ================== //

//   Future<void> putObject<T>(String key, T? object) async {
//     final box = await _safeBox;
//     if (object == null) {
//       await box.delete(_objectPrefix + key);
//     } else {
//       await box.put(_objectPrefix + key, object);
//     }
//   }

//   Future<T?> getObject<T>(String key) async {
//     final box = await _safeBox;
//     return box.get(_objectPrefix + key) as T?;
//   }

//   // ================== 集合存储 ================== //

//   Future<void> putList<T>(String key, List<T> list) async {
//     final box = await _safeBox;
//     if (list.isEmpty) {
//       await box.delete(_collectionPrefix + key);
//     } else {
//       await box.put(_collectionPrefix + key, list);
//     }
//   }

//   Future<List<T>?> getList<T>(String key) async {
//     final box = await _safeBox;
//     final list = box.get(_collectionPrefix + key);
//     return list is List ? List<T>.from(list) : null;
//   }

//   Future<void> putMap<K, V>(String key, Map<K, V> map) async {
//     final box = await _safeBox;
//     if (map.isEmpty) {
//       await box.delete(_collectionPrefix + key);
//     } else {
//       await box.put(_collectionPrefix + key, map);
//     }
//   }

//   Future<Map<K, V>?> getMap<K, V>(String key) async {
//     final box = await _safeBox;
//     final map = box.get(_collectionPrefix + key);
//     return map is Map ? Map<K, V>.from(map) : null;
//   }

//   // ================== 其他操作 ================== //

//   Future<void> delete(String key) async {
//     final box = await _safeBox;
//     await box.delete(key);
//     await box.delete(_collectionPrefix + key);
//     await box.delete(_objectPrefix + key);
//   }

//   Future<void> clear() async {
//     final box = await _safeBox;
//     await box.clear();
//   }

//   bool containsKey(String key) {
//     return _box?.containsKey(key) == true || _box?.containsKey(_collectionPrefix + key) == true || _box?.containsKey(_objectPrefix + key) == true;
//   }
// }
