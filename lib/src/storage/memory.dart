import 'dart:async';

import 'implements.dart' show Storage;

class Memory implements Storage {
  Memory();

  Map<String, dynamic> fileSourceMap = {};
  Map<String, String> fileReNameMap = {};

  bool get supported => true;

  Future<void> ready() async {}

  bool existsSync(String path) {
    return fileSourceMap.containsKey(path) || fileReNameMap.containsKey(path);
  }

  Future<bool> exists(String path) {
    Completer<bool> _completer = Completer<bool>();
    _completer.complete(fileSourceMap.containsKey(path) || fileReNameMap.containsKey(path));
    return _completer.future;
  }

  Future<dynamic> write(String path, dynamic value) {
    fileSourceMap.addAll({path: value});
    return value;
  }

  dynamic writeAsync(String path, dynamic value) {
    fileSourceMap.addAll({path: value});
    return value;
  }

  void remove(String path) {
    if (fileSourceMap.containsKey(path)) {
      fileSourceMap.remove(path);
    }
    if (fileSourceMap.containsKey(path)) {
      fileSourceMap.remove(path);
    }
  }

  Future<void> rename(String path, String newPath) async {
    Completer<void> _completer = Completer<void>();
    fileReNameMap.addAll({newPath: path});
    _completer.complete();
    return _completer.future;
  }

  Future<dynamic?> read(String key) {
    Completer<dynamic> _completer = Completer<dynamic>();
    if (fileSourceMap.containsKey(key)) {
      _completer.complete(fileSourceMap[key]);
    }
    if (fileReNameMap.containsKey(key)) {
      String rePath = fileReNameMap[key]!;
      _completer.complete(fileSourceMap[rePath]);
    }
    return _completer.future;
  }

  dynamic? readAsync(String path) {
    if (fileSourceMap.containsKey(path)) {
      return fileSourceMap[path];
    }
    if (fileReNameMap.containsKey(path)) {
      String rePath = fileReNameMap[path]!;
      return fileSourceMap[rePath];
    }
    return null;
  }

  /// 清空数据
  Future<void> clear() async {
    return fileSourceMap.clear();
  }
}
