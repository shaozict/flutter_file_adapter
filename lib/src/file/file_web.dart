import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'file_store.dart';

export 'file_store.dart';

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
    // print('file writeAsBytes path: $path, ${bytes.length}');
    _completer.complete(this);
    return _completer.future;
  }

  void writeAsBytesSync(List<int> bytes, {bool flush = false}) {
    String fileName = path;
    if (path.contains('/')) {
      fileName = path.split('/').last;
    }
    html.File file = GlobalFileStore.instance.readBitsAsFile(bytes, fileName);
    // print('file writeAsBytesSync path: $path, ${bytes.length}');
    GlobalFileStore.instance.store(
      path,
      file,
      bytes: bytes,
    );
  }

  Future<Uint8List> readAsBytes() {
    Completer<Uint8List> _completer = Completer<Uint8List>();
    html.File file = GlobalFileStore.instance.readAsFile(path)!;
    html.FileReader reader = html.FileReader();
    List<int> list = [];
    if (GlobalFileStore.instance.existsSync(path)) {
      list = GlobalFileStore.instance.readAsBytesAsync(path)!;
      _completer.complete(Uint8List.fromList(list));
      return _completer.future;
    }
    reader.onLoad.listen((event) {
      _completer.complete(Uint8List.fromList(list));
    });
    reader.readAsArrayBuffer(file);
    return _completer.future;
  }

  Uint8List readAsBytesSync() {
    // 支持直接存储二进制
    assert(true, 'web端不支持同步读取文件');
    List<int> list = GlobalFileStore.instance.readAsBytesAsync(path)!;
    if (list.isEmpty) {
      list = [];
    }
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
