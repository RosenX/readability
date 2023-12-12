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
    case 'v1':
      method = Method.readability;
      break;
    case 'v2':
      method = Method.readabilityV2;
      break;
    default:
      method = Method.readabilityV2;
      break;
  }
  final inputFile = args[1];

  final htmlFile = File(inputFile);
  final content = await htmlFile.readAsString();

  var extractor = HtmlExtractor(
    html: content,
    method: method,
    isDebug: true,
    title: "HelloGitHub 第 92 期",
  );
  var result = extractor.parse();

  var outputFile = File('clean.html');
  outputFile.writeAsString(result?.html ?? '');
}
