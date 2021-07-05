import 'dart:async';

class Directory {
  Directory(this.path);
  final String path;

  bool existsSync() {
    return false;
  }

  void deleteSync({bool recursive = false}) {
    assert(true, 'web端无需删除');
  }

  Future<Directory> create({bool recursive = false}) {
    Completer<Directory> _completer = Completer<Directory>();
    _completer.complete(this);
    return _completer.future;
  }

  void createSync({bool recursive = false}) {
    assert(true, 'web端无需创建');
  }
}
