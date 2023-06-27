import 'dart:convert';
import 'dart:io';

import 'package:readability/readability.dart';

import 'test_case.dart';

Future<void> runTestOutput(String caseFolder, String outputFolder) async {
  final caseDir = Directory(caseFolder);
  final List<FileSystemEntity> entities = await caseDir.list().toList();
  final Iterable<File> files = entities.whereType<File>();
  for (final file in files) {
    final outputName = '$outputFolder/${file.path.split('/').last}';

    final htmlFile = File(file.path);
    final content = await htmlFile.readAsString();
    var extractor = HtmlExtractor(rawHtml: content, method: Method.readability);
    var result = extractor.parse();
    var outputFile = File(outputName);
    outputFile.writeAsStringSync(result);
  }
}

List<TestCase> runTest(String outputFolder, String expectFolder) {
  final outputDir = Directory(outputFolder);
  final expectDir = Directory(expectFolder);
  final List<FileSystemEntity> entities = outputDir.listSync();
  final Iterable<File> files = entities.whereType<File>();

  final List<TestCase> testCases = [];

  for (final file in files) {
    final expectFile = File('${expectDir.path}/${file.path.split('/').last}');
    if (!expectFile.existsSync()) {
      testCases.add(TestCase(
          filename: file.path.split('/').last, isNew: true, isPassed: false));
      continue;
    }
    final expectContent = expectFile.readAsStringSync();
    final outputContent = file.readAsStringSync();
    if (expectContent != outputContent) {
      testCases.add(TestCase(
          filename: file.path.split('/').last, isNew: true, isPassed: false));
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

  await runTestOutput(caseDir, outputDir);
  final caseNeedCheck = runTest(outputDir, expectDir);

  String jsonString = JsonEncoder.withIndent('  ').convert(caseNeedCheck);

  // write cases need check to json file
  final jsonFile = File('cases_need_check.json');
  jsonFile.writeAsStringSync(jsonString);

  print("You have ${caseNeedCheck.length} cases need check.");
}
