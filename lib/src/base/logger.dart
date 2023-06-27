import 'dart:io';

import 'package:html/dom.dart';

mixin Logger {
  void log(String fileName, Document doc) {
    var file = File('log/$fileName.html');
    file.writeAsString(doc.outerHtml);
  }
}
