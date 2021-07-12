import 'dart:async';
import 'dart:html' as html;
import 'dart:indexed_db';

import 'implements.dart' show Storage;

class IndexDb implements Storage {
  IndexDb({
    this.storeName = 'my_indexed_db_store',
    this.version = 1,
  });
  final String storeName;
  final int version;
  final dbSourceMapKey = 'DB_SOURCE_MAP_KEY';
  Database? db;

  Map<String, dynamic> sourceMap = {};

  bool get supported => IdbFactory.supported;

  Future ready() async {
    await this.open();
  }

  Future<Database?> open() async {
    if (IdbFactory.supported) {
      Database db = await html.window.indexedDB!.open(
        'my_indexed_db',
        version: this.version,
        onUpgradeNeeded: (event) {
          // 保存 IDBDataBase 接口
          var db = event.target.result;
          // 为该数据库创建一个对象仓库
          if (!db.objectStoreNames!.contains(this.storeName)) {
            db.createObjectStore(this.storeName);
          }
        },
      );

      this.db = db;
      // 设置同步内容key存在表
      List<String> keys = await this.getAllKeys();
      _setKeysForSourceMap(keys);
      return db;
    } else {
      Completer<Database> _completer = Completer<Database>();
      _completer.complete(null);
      return _completer.future;
    }
  }

  /// 添加数据
  Future<dynamic> write(
    String key,
    dynamic value,
  ) async {
    await Future.wait([_write(key, value), setKey(key)]);

    _setSourceMap(key, true);
    return value;
  }

  // 添加数据，同步
  dynamic writeAsync(
    String key,
    dynamic value,
  ) {
    _setSourceMap(key, value);
    _write(key, value).then((value) {
      _setSourceMap(key, true);
    });
    return value;
  }

  /// 获取数据
  Future<dynamic> read(String key) async {
    dynamic request = await _read(key);
    return request;
  }

  /// 移除数据
  Future<void> remove(String key) async {
    await Future.wait([db!.transaction(this.storeName, 'readwrite').objectStore(this.storeName).delete(key), removeKey(key)]);
    _remove(key);
  }

  /// 判断是否存在数据
  Future<bool> exists(String key) async {
    return await _exists(key);
  }

  /// 判断是否存在数据，同步
  bool existsSync(String key) {
    return sourceMap.containsKey(key);
  }

  /// 清空数据
  Future<void> clear() async {
    _clearSourceMap();
    await Future.wait([db!.transaction(this.storeName, 'readwrite').objectStore(this.storeName).clear(), remove(dbSourceMapKey)]);
  }

  /// 重名面
  @override
  Future<void> rename(String key, String newKey) async {
    if (existsSync(key)) {
      dynamic data = await _read(key);
      await write(newKey, data);
      return;
    }
  }

  /// 获取存储内容所有key
  Future<List<String>> getAllKeys() async {
    if (await _exists(dbSourceMapKey)) {
      return await _read(dbSourceMapKey);
    }
    return Future.value([]);
  }

  /// 设置存储记录
  Future<void> setKey(String key) async {
    if (!await _exists(dbSourceMapKey)) {
      await _write(dbSourceMapKey, [key]);
    } else {
      List keys = await _read(dbSourceMapKey);
      keys.add(key);
      await _write(dbSourceMapKey, keys);
    }
  }

  /// 移除记录
  Future<void> removeKey(String key) async {
    if (await _exists(dbSourceMapKey)) {
      List keys = await _read(dbSourceMapKey);
      keys.remove(key);
      await _write(dbSourceMapKey, keys);
    }
  }

  _setKeysForSourceMap(List<String> keys) {
    keys.forEach((String key) {
      sourceMap.addAll({key: true});
    });
  }

  _setSourceMap(String key, dynamic value) {
    sourceMap.addAll({key: value});
  }

  _clearSourceMap() {
    sourceMap.clear();
  }

  _remove(String key) {
    sourceMap.remove(key);
  }

  Future<dynamic> _read(String key) async {
    dynamic request = await db!.transaction(this.storeName, 'readonly').objectStore(this.storeName).getObject(key);

    return request;
  }

  Future<dynamic> _write(
    String key,
    dynamic value,
  ) async {
    await db!.transaction(this.storeName, 'readwrite').objectStore(this.storeName).put(value, key);

    return value;
  }

  Future<bool> _exists(String key) async {
    int count = await db!.transaction(this.storeName, 'readonly').objectStore(this.storeName).count(key);

    return count > 0;
  }
}
