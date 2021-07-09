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
      );
      if (!db.objectStoreNames!.contains(this.storeName)) {
        db.createObjectStore(this.storeName);
      }
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
    await db!.transaction(this.storeName, 'readwrite').objectStore(this.storeName).put(value, key);
    _setSourceMap(key, true);
    return value;
  }

  // 添加数据，同步
  dynamic writeAsync(
    String key,
    dynamic value,
  ) {
    _setSourceMap(key, value);
    write(key, value).then((value) {
      _setSourceMap(key, true);
    });
    return value;
  }

  /// 获取数据
  Future<dynamic> read(String key) async {
    dynamic request = await db!.transaction(this.storeName, 'readonly').objectStore(this.storeName).getObject(key);
    return request;
  }

  /// 移除数据
  remove(String key) async {
    dynamic request = await db!.transaction(this.storeName, 'readwrite').objectStore(this.storeName).delete(key);
    _remove(key);
    return request.result;
  }

  /// 判断是否存在数据
  Future<bool> exists(String key) async {
    int count = await db!.transaction(this.storeName, 'readonly').objectStore(this.storeName).count(key);
    return count > 0;
  }

  /// 判断是否存在数据，同步
  bool existsSync(String key) {
    return sourceMap.containsKey(key);
  }

  /// 清空数据
  Future<void> clear() async {
    _clearSourceMap();
    return await db!.transaction(this.storeName, 'readwrite').objectStore(this.storeName).clear();
  }

  /// 重名面
  @override
  Future<void> rename(String key, String newKey) async {
    if (existsSync(key)) {
      dynamic data = await read(key);
      await write(newKey, data);
      return;
    }
  }

  /// 获取存储内容所有key
  Future<List<String>> getAllKeys() async {
    dynamic request = await db!.transaction(this.storeName, 'readonly').objectStore(this.storeName).getAllKeys({});
    return request.result;
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
}
