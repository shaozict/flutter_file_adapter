import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

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

  Future<String> store(String path, html.File file, {List<int>? bytes}) async {
    storage.write(path, file);
    if (bytes!.isNotEmpty) {
      await storage.write('$path.bytes', file);
      return path;
    }
    return Future.value(path);
  }

  String storeAsync(String path, html.File file, {List<int>? bytes}) {
    storage.writeAsync(path, file);
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

  Future<String> globalPath(String path) async {
    html.File file = await storage.read(path);
    String gPath = html.Url.createObjectUrl(file);
    return gPath;
  }

  String bytesToGlobalPath(List<Object> fileBits) {
    html.File file = readBitsAsFile(fileBits, '');
    String globalPath = html.Url.createObjectUrl(file);
    return globalPath;
  }

  Future<html.File> readAsFile(String path) async {
    return await storage.read(path);
  }

  Future<Uint8List> readAsBytes(String path) async {
    Completer<Uint8List> _completer = Completer<Uint8List>();
    html.File file = await storage.read(path);
    if (storage.existsSync('$path.bytes')) {
      Uint8List list = await storage.read('$path.bytes');
      _completer.complete(Uint8List.fromList(list));
      return _completer.future;
    }
    return await readFileToBytes(file);
  }

  Future<Uint8List> readFileToBytes(html.File file) async {
    html.FileReader reader = html.FileReader();
    Completer<Uint8List> _completer = Completer<Uint8List>();
    List<int> list = [];
    reader.onLoad.listen((event) {
      _completer.complete(Uint8List.fromList(list));
    });
    reader.readAsArrayBuffer(file);
    return _completer.future;
  }
}
