import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:logging/logging.dart';

import 'file_store.dart';

export 'file_store.dart';

Logger _log = Logger('file_Web');

class File {
  File(this.path);
  final String path;

  bool get isFile => true;

  bool existsSync() {
    if (GlobalFileStore.instance.existsSync(path)) {
      return true;
    }
    return false;
  }

  Future<File> writeAsBytes(List<int> bytes, {bool flush = false}) {
    Completer<File> _completer = Completer<File>();
    String fileName = path;
    if (path.contains('/')) {
      fileName = path.split('/').last;
    }
    html.File file = GlobalFileStore.instance.readBitsAsFile(bytes, fileName);
    GlobalFileStore.instance.store(
      path,
      file,
      bytes: bytes,
    );
    _completer.complete(this);
    return _completer.future;
  }

  void writeAsBytesSync(List<int> bytes, {bool flush = false}) {
    String fileName = path;
    if (path.contains('/')) {
      fileName = path.split('/').last;
    }
    html.File file = GlobalFileStore.instance.readBitsAsFile(bytes, fileName);
    GlobalFileStore.instance.store(
      path,
      file,
      bytes: bytes,
    );
  }

  Future<Uint8List> readAsBytes(path) async {
    return await GlobalFileStore.instance.readAsBytes(path);
  }

  Uint8List readAsBytesSync() {
    // 支持直接存储二进制
    _log.info('web端不支持同步读取文件');
    List<int> list = [];
    return Uint8List.fromList(list);
  }

  File renameSync(String newPath) {
    GlobalFileStore.instance.rename(path, newPath);
    return File(newPath);
  }

  void createSync({bool recursive = false}) {
    GlobalFileStore.instance.store(
      path,
      html.File([], ''),
      bytes: [],
    );
  }
}
