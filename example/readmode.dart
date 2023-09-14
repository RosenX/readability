import 'dart:io';

import 'package:readability/src/html_extractor.dart';

void main(List<String> args) async {
  var inputFile = args[0];

  final htmlFile = File(inputFile);
  final content = await htmlFile.readAsString();

  var extractor = HtmlExtractor(
    rawHtml: content,
    method: Method.readability,
    isDebug: true,
  );
  var result = extractor.parse();

  var outputFile = File('clean.html');
  outputFile.writeAsString(result?.html ?? '');
  print(result?.contentLength);
}
