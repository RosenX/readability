import 'dart:io';

import 'package:readability/readability.dart';

void runFile(String caseFolder, String outputFolder, {bool isClean = false}) {
  final caseDir = Directory(caseFolder);
  if (!Directory(outputFolder).existsSync()) {
    Directory(outputFolder).createSync(recursive: true);
  }
  final List<FileSystemEntity> entities = caseDir.listSync().toList();
  final Iterable<File> files = entities.whereType<File>();
  for (final file in files) {
    final outputName = '$outputFolder/${file.path.split('/').last}';

    final htmlFile = File(file.path);
    final content = htmlFile.readAsStringSync();
    try {
      var extractor = HtmlExtractor(
        rawHtml: content,
        method: Method.blockDensity,
        onlyClean: isClean,
      );
      var result = extractor.parse();
      var outputFile = File(outputName);
      outputFile.writeAsStringSync(result?.html ?? '');
    } catch (e) {
      continue;
    }
  }
}

void runDir(String caseFolder, String outputFolder, {bool isClean = false}) {
  final caseDir = Directory(caseFolder);
  final List<FileSystemEntity> entities = caseDir.listSync().toList();
  final Iterable<Directory> subDirs = entities.whereType<Directory>();
  for (final subDir in subDirs) {
    final dirName = subDir.path.split('/').last;
    runFile('$caseFolder/$dirName', '$outputFolder/$dirName', isClean: isClean);
  }
}

void main(List<String> args) async {
  String mode = 'extract';
  if (args.isNotEmpty && args.first == 'clean') {
    mode = 'clean';
  }

  final caseDir = 'cases';
  final outputDir = 'cases_output';

  runDir(caseDir, outputDir, isClean: mode == 'clean');
  // fromat output html
  await Process.run('npx', 'prettier -w $outputDir'.split(' '));
}
