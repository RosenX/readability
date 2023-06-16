import 'dart:io';

import 'package:readability/readability.dart';

void main(List<String> args) async {
  var inputFile = args[0];

  final htmlFile = File(inputFile);
  final content = await htmlFile.readAsString();

  var doc = HtmlDocument(input: content);

  var outputFile = File('clean.html');
  try {
    var result = doc.parse();
    outputFile.writeAsString(result ? doc.pureHtml : "not support page");
  } catch (e) {
    outputFile.writeAsString(e.toString());
  }
}
