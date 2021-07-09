abstract class Storage {
  Storage();

  bool get supported => false;

  Future<void> ready() async {}

  /// 添加数据
  Future<dynamic> write(
    String key,
    dynamic value,
  ) async {}

  /// 获取数据
  Future<dynamic> read(String key) async {}

  /// 移除数据
  remove(String key) async {}

  /// 是否存在数据
  Future<bool> exists(String key) async {
    return false;
  }

  /// 清空数据
  void clear() {}

  /// 重命名
  Future<void> rename(String key, String newKey) async {}

  bool existsSync(String path) {
    return false;
  }

  dynamic writeAsync(String path, dynamic value) {}
}
