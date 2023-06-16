import 'dart:io';

import 'package:readability/readability.dart';

void main() async {
  final caseDir = Directory('../test_cases');
  final outputDir = '../test_cases_output';

  final List<FileSystemEntity> entities = await caseDir.list().toList();

  final Iterable<File> files = entities.whereType<File>();

  for (final file in files) {
    final outputName = '$outputDir/${file.path.split('/').last}';
    final htmlFile = File(file.path);

    final content = await htmlFile.readAsString();

    var doc = HtmlDocument(input: content);
    File outputFile = File(outputName);

    try {
      var result = doc.parse();
      outputFile.writeAsString(result ? doc.pureHtml : "not support page");
    } catch (e) {
      outputFile.writeAsString(e.toString());
    }
  }
}
