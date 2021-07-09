import 'dart:indexed_db';

import 'db.dart';
import 'implements.dart';
import 'memory.dart';

Storage createStorage() {
  if (IdbFactory.supported) {
    return IndexDb();
  }
  return Memory();
}
