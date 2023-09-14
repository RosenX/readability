import 'dart:io';

import 'package:readability/src/html_extractor.dart';

void main(List<String> args) async {
  var inputFile = args[0];

  final htmlFile = File(inputFile);
  var content = await htmlFile.readAsString();

  content = "xxxsdfwefxcfxdwefsdfe";

  var extractor = HtmlExtractor(
      rawHtml: content,
      method: Method.readability,
      isDebug: true,
      title: "aaaa",
      onlyClean: true);
  var result = extractor.parse();

  var outputFile = File('clean.html');
  outputFile.writeAsString(result?.html ?? '');
}
