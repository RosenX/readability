import 'dart:io';

import 'package:readability/html_extractor.dart';

void main(List<String> args) async {
  var inputFile = args[0];

  final htmlFile = File(inputFile);
  final content = await htmlFile.readAsString();

  var extractor = HtmlExtractor(rawHtml: content, method: Method.readability);
  var result = extractor.parse();

  var outputFile = File('clean.html');
  outputFile.writeAsString(result);
}
