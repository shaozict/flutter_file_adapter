import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

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
    html.File file = GlobalFileStore.instance.readAsFile(path);
    html.FileReader reader = html.FileReader();
    List<int> list = [];
    // print(
    //     'file readAsBytes path: $path: ${GlobalFileStore.instance.fileReNameMap.keys.toString()}');
    if (GlobalFileStore.instance.existsSync(path)) {
      // print('file readAsBytes value1');
      list = GlobalFileStore.instance.readAsBytesAsync(path);
      _completer.complete(Uint8List.fromList(list));
      return _completer.future;
    }
    reader.onLoad.listen((event) {
      // print('file readAsBytes value: ${event.target}');

      _completer.complete(Uint8List.fromList(list));
    });
    reader.readAsArrayBuffer(file);
    return _completer.future;
  }

  Uint8List readAsBytesSync() {
    // 支持直接存储二进制
    assert(true, 'web端不支持同步读取文件');
    List<int> list = GlobalFileStore.instance.readAsBytesAsync(path);
    if (list == null || list.isEmpty) {
      list = [];
    }
    // print('file readAsBytesSync path: $path, ${list.length}');
    return Uint8List.fromList(list);
  }

  File renameSync(String newPath) {
    // print('renameSync: $path, $newPath');
    GlobalFileStore.instance.rename(path, newPath);
    return File(newPath);
  }

  void createSync({bool recursive = false}) {
    // print('createSync web端创建');
    GlobalFileStore.instance.store(
      path,
      html.File([], ''),
      bytes: [],
    );
  }
}

class GlobalFileStore {
  GlobalFileStore._();

  static GlobalFileStore _instance;

  static GlobalFileStore get instance => _getInstance();

  static GlobalFileStore _getInstance() => _instance ??= GlobalFileStore._();

  Map<String, html.File> fileSourceMap = {};
  Map<String, List<int>> fileSourceBytesMap = {};
  Map<String, String> fileReNameMap = {};

  bool existsSync(String path) {
    // print(
    //     'file existsSync: $path : ${fileSourceMap.containsKey(path) || fileReNameMap.containsKey(path)}. ${fileSourceMap.keys.toString()}.${fileReNameMap.keys.toString()}');
    return fileSourceMap.containsKey(path) || fileReNameMap.containsKey(path);
  }

  html.File readBitsAsFile(
    List<Object> fileBits,
    String fileName,
  ) {
    return html.File([fileBits], fileName, {'type': ''});
  }

  String store(String path, html.File file, {List<int> bytes}) {
    // String path = html.Url.createObjectUrl(file);
    fileSourceMap.addAll({path: file});
    if (bytes.isNotEmpty) {
      fileSourceBytesMap.addAll({path: bytes});
      // print(
      //     'store fileSourceBytesMap: ${fileSourceBytesMap.keys.toString()}, $path, ${bytes.length}');
    }
    return path;
  }

  void clear(String path) {
    if (fileSourceMap.containsKey(path)) {
      fileSourceMap.remove(path);
    }
    if (fileSourceBytesMap.containsKey(path)) {
      fileSourceBytesMap.remove(path);
    }
  }

  void rename(String path, String newPath) {
    fileReNameMap.addAll({newPath: path});

    // print('rename fileReNameMap: ${fileReNameMap.keys.toString()}: ${newPath}');
  }

  String globalPath(String path) {
    html.File file = fileSourceMap[path];
    String gPath = html.Url.createObjectUrl(file);
    return gPath;
  }

  String bytesToPath(List<Object> fileBits) {
    html.File file = readBitsAsFile(fileBits, '');
    String path = html.Url.createObjectUrl(file);
    fileSourceMap.addAll({'$path': file});
    return path;
  }

  html.File readAsFile(String path) {
    if (fileSourceMap.containsKey(path)) {
      return fileSourceMap[path];
    }
    if (fileReNameMap.containsKey(path)) {
      String rePath = fileReNameMap[path];
      return fileSourceMap[rePath];
    }
    return null;
  }

  Uint8List readAsBytesAsync(String path) {
    if (fileSourceBytesMap.containsKey(path)) {
      return fileSourceBytesMap[path];
    }
    if (fileReNameMap.containsKey(path)) {
      String rePath = fileReNameMap[path];
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
