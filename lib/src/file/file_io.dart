export 'dart:io' show File;

// class GlobalFileStore {
//   GlobalFileStore._();
//
//   static GlobalFileStore _instance;
//
//   static GlobalFileStore get instance => _getInstance();
//
//   static GlobalFileStore _getInstance() => _instance ??= GlobalFileStore._();
//
//   bool existsSync(String path) {
//     return false;
//   }
//
//   File readBitsAsFile(
//     List<Object> fileBits,
//     String fileName,
//   ) {
//     assert(false, '不支持客户端');
//     return null;
//   }
//
//   String store(String path, File file, {List<int> bytes}) {
//     return null;
//   }
//
//   void clear(String path) {
//     assert(false, '不支持客户端');
//   }
//
//   void rename(String path, String newPath) {
//     assert(false, '不支持客户端');
//   }
//
//   String globalPath(String path) {
//     assert(false, '不支持客户端');
//     return null;
//   }
//
//   String bytesToPath(List<Object> fileBits) {
//     assert(false, '不支持客户端');
//     return null;
//   }
//
//   File readAsFile(String path) {
//     assert(false, '不支持客户端');
//     return null;
//   }
//
//   Uint8List readAsBytesAsync(String path) {
//     assert(false, '不支持客户端');
//     return null;
//   }
//
//   bool pathIsExist(String path) {
//     assert(false, '不支持客户端');
//     return false;
//   }
// }
