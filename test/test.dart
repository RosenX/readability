import 'dart:io';

import 'package:readability/readability.dart';

import 'test_case.dart';

void runTestOutputFile(String caseFolder, String outputFolder) {
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
      var extractor =
          HtmlExtractor(rawHtml: content, method: Method.readability);
      var result = extractor.parse();
      var outputFile = File(outputName);
      outputFile.writeAsStringSync(result?.html ?? '');
    } catch (e) {
      continue;
    }
  }
}

void runTestOutput(String caseFolder, String outputFolder) {
  final caseDir = Directory(caseFolder);
  final List<FileSystemEntity> entities = caseDir.listSync().toList();
  final Iterable<Directory> subDirs = entities.whereType<Directory>();
  for (final subDir in subDirs) {
    final dirName = subDir.path.split('/').last;
    runTestOutputFile('$caseFolder/$dirName', '$outputFolder/$dirName');
  }
}

List<TestCase> runTest(String outputFolder, String expectFolder) {
  final outputDir = Directory(outputFolder);
  final List<FileSystemEntity> entities = outputDir.listSync().toList();
  final Iterable<Directory> subDirs = entities.whereType<Directory>();

  final List<TestCase> testCases = [];

  for (final subDir in subDirs) {
    final dirName = subDir.path.split('/').last;
    List<TestCase> result =
        runTestFile('$outputFolder/$dirName', '$expectFolder/$dirName');
    testCases.addAll(result);
  }
  return testCases;
}

List<TestCase> runTestFile(String outputFolder, String expectFolder) {
  final outputDir = Directory(outputFolder);
  final expectDir = Directory(expectFolder);
  final List<FileSystemEntity> entities = outputDir.listSync();
  final Iterable<File> files = entities.whereType<File>();

  final List<TestCase> testCases = [];

  for (final file in files) {
    final expectFile = File('${expectDir.path}/${file.path.split('/').last}');
    if (!expectFile.existsSync()) {
      testCases.add(TestCase(
        output: file.path,
        expect: expectFile.path,
        isNew: true,
      ));
      continue;
    }
    final expectContent = expectFile.readAsStringSync();
    final outputContent = file.readAsStringSync();
    if (expectContent != outputContent) {
      testCases.add(TestCase(
        output: file.path,
        expect: expectFile.path,
        isNew: false,
      ));
    } else {
      // remove output file if passed
      file.deleteSync();
    }
  }
  return testCases;
}

void main() async {
  final caseDir = 'cases';
  final expectDir = 'cases_expect';
  final outputDir = 'cases_output';

  runTestOutput(caseDir, outputDir);
  // fromat output html
  await Process.run('npx', 'prettier -w $outputDir'.split(' '));

  final caseNeedCheck = runTest(outputDir, expectDir);
  saveTestCases(caseNeedCheck);
  print("You have ${caseNeedCheck.length} cases need check.");
}
