library flutter_file_adapter;

export 'src/directory/directory_io.dart'
    if (dart.library.io) 'src/directory/directory_io.dart' // dart:io
    if (dart.library.html) 'src/directory/directory_web.dart'; // dart:html
export 'src/file/file_io.dart'
    if (dart.library.io) 'src/file/file_io.dart' // dart:io
    if (dart.library.html) 'src/file/file_web.dart'; // dart:html
