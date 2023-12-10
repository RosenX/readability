import 'dart:io';

mixin Logger {
  void logger(String fileName, String doc) {
    var file = File('log/$fileName.html');
    file.writeAsStringSync(doc);
  }
}
