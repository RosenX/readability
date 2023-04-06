import 'package:readability/readability.dart';
import 'dart:io';

void main() async {
  final htmlFile = File('test.html');

  final content = await htmlFile.readAsString();

  var doc = HtmlDocument(input: content);

  doc.parse();
}
