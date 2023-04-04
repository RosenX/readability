import 'package:readability/readability.dart';
import 'dart:io';

void main() async {
  final htmlFile = File('bin/test.html');

  final content = await htmlFile.readAsString();

  var doc = HtmlDocument(input: content);
  doc.parse();
  doc.html.querySelectorAll('div').first.attributes.remove('id');
  print(doc.html.outerHtml);
}
