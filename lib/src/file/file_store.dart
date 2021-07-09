import 'dart:html' as html;

import 'package:flutter_file_adapter/src/storage/implements.dart';
import 'package:flutter_file_adapter/src/storage/storage.dart';

class GlobalFileStore {
  GlobalFileStore._();

  static GlobalFileStore _instance = GlobalFileStore._();

  static GlobalFileStore get instance => _getInstance();

  static GlobalFileStore _getInstance() => _instance;

  Map<String, html.File> fileSourceMap = {};
  Map<String, List<int>> fileSourceBytesMap = {};
  Map<String, String> fileReNameMap = {};

  Storage storage = createStorage();

  Future<void> ready() async {
    await storage.ready();
  }

  bool existsSync(String path) {
    return storage.existsSync(path);
  }

  html.File readBitsAsFile(
    List<Object> fileBits,
    String fileName,
  ) {
    return html.File([fileBits], fileName, {'type': ''});
  }

  String store(String path, html.File file, {List<int>? bytes}) {
    storage.write(path, file);
    if (bytes!.isNotEmpty) {
      storage.write('$path.bytes', file);
    }
    return path;
  }

  void clear(String path) {
    if (storage.existsSync(path)) {
      storage.remove(path);
    }
    // 同步清掉，备份二进制数据
    if (storage.existsSync('$path.bytes')) {
      fileSourceBytesMap.remove('$path.bytes');
    }
  }

  void rename(String path, String newPath) {
    storage.rename(path, newPath);
  }

  Future<String> globalPath(String path) {
    html.File file = storage.read(path);
    String gPath = html.Url.createObjectUrl(file);
    return gPath;
  }

  String bytesToPath(List<Object> fileBits) {
    html.File file = readBitsAsFile(fileBits, '');
    String path = html.Url.createObjectUrl(file);
    fileSourceMap.addAll({'$path': file});
    return path;
  }

  html.File? readAsFile(String path) {
    if (fileSourceMap.containsKey(path)) {
      return fileSourceMap[path];
    }
    if (fileReNameMap.containsKey(path)) {
      String rePath = fileReNameMap[path]!;
      return fileSourceMap[rePath];
    }
    return null;
  }

  List<int>? readAsBytesAsync(String path) {
    if (fileSourceBytesMap.containsKey(path)) {
      return fileSourceBytesMap[path];
    }
    if (fileReNameMap.containsKey(path)) {
      String rePath = fileReNameMap[path]!;
      return fileSourceBytesMap[rePath];
    }
    return null;
  }

  bool pathIsExist(String path) {
    if (fileSourceMap.containsKey(path)) {
      return true;
    }
    return false;
  }
}
