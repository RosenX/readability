import 'package:readability/readability.dart';
import 'package:html/parser.dart' as parser;
import 'dart:io';

void main() async {
  final htmlFile = File('bin/test.html');

  final content = await htmlFile.readAsString();

  var doc = HtmlDocument(input: content);

  doc.parse();

  print(doc.pureHtml);
}
