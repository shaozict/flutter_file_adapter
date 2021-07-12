import 'package:flutter_file_adapter/flutter_file_adapter.dart';
import 'package:test/test.dart';

void main() {
  test('file.existsSync', () {
    var file = File('1');
    expect(file.existsSync(), equals(false));
  });
}
