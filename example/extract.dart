import 'dart:io';

import 'package:readability/src/html_extractor.dart';

void main(List<String> args) async {
  if (args.length < 2) {
    print(
        'Please give args like: dart extract.dart [readability|blockDensity] input.html');
    return;
  }
  Method method;
  switch (args[0]) {
    case 'readabilidy':
      method = Method.readability;
      break;
    case 'blockDensity':
      method = Method.blockDensity;
      break;
    default:
      method = Method.readability;
      break;
  }
  final inputFile = args[1];

  final htmlFile = File(inputFile);
  final content = await htmlFile.readAsString();

  var extractor = HtmlExtractor(
    rawHtml: content,
    method: method,
    isDebug: true,
  );
  var result = extractor.parse();

  var outputFile = File('clean.html');
  outputFile.writeAsString(result?.html ?? '');
}
