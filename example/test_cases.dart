import 'dart:io';

import 'package:readability/readability.dart';

void main() async {
  final caseDir = Directory('../test_cases');
  final outputDir = '../test_cases_output';
  // remove output dir if exists
  final outputDirFile = Directory(outputDir);
  if (outputDirFile.existsSync()) {
    outputDirFile.deleteSync(recursive: true);
  }
  // create output dir
  outputDirFile.createSync();

  final List<FileSystemEntity> entities = await caseDir.list().toList();

  final Iterable<File> files = entities.whereType<File>();

  for (final file in files) {
    final outputName = '$outputDir/${file.path.split('/').last}';
    final htmlFile = File(file.path);

    final content = await htmlFile.readAsString();
    var extractor = HtmlExtractor(rawHtml: content, method: Method.readability);

    var result = extractor.parse();
    var outputFile = File(outputName);
    outputFile.writeAsString(result);
  }
}
