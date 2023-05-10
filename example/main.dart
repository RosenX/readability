import 'package:readability/readability.dart';
import 'dart:io';

void main() async {
  final htmlFile = File('test.html');

  final content = await htmlFile.readAsString();

  var doc = HtmlDocument(input: content);

  var result = doc.parse();
  if (result) {
    print(doc.pureHtml);
  } else {
    print('not support page');
  }
}
