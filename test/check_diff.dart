import 'dart:convert';
import 'dart:io';
import 'test_case.dart';

void main(List<String> args) async {
  var jsonFile = File('cases_need_check.json');
  String jsonString = await jsonFile.readAsString();

  List<TestCase> testCases = jsonDecode(jsonString).map<TestCase>((e) {
    return TestCase.fromJson(e);
  }).toList();

  if (testCases.isEmpty) return;

  if (args.isEmpty) {
    if (testCases.first.isNew) {
      print(testCases.first.output);
    } else {
      final result = await Process.run('diff', [
        testCases.first.output,
        testCases.first.expect,
      ]);
      print(result.stdout);
      print("diff '${testCases.first.output}' '${testCases.first.expect}'");
    }
  } else if (args.first == 'pass') {
    // move the first output file to expect file
    moveFile(testCases.first.output, testCases.first.expect);
    testCases.removeAt(0);
    saveTestCases(testCases);
  } else if (args.first == 'pass-all') {
    // move all output file to expect file
    for (var testCase in testCases) {
      moveFile(testCase.output, testCase.expect);
    }
    testCases = [];
    saveTestCases(testCases);
  }
}

void moveFile(String from, String to) {
  var output = File(from);
  var expect = File(to);
  if (!expect.existsSync()) {
    expect.createSync(recursive: true);
  }
  expect.writeAsStringSync(output.readAsStringSync());
  output.deleteSync();
}
