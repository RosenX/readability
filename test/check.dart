import 'dart:convert';
import 'dart:io';

import 'test_case.dart';

void main() async {
  var outputFolder = 'cases_output';
  var expectFolder = 'cases_expect';
  var jsonFile = File('cases_need_check.json');
  String jsonString = await jsonFile.readAsString();

  List<TestCase> testCases = jsonDecode(jsonString).map<TestCase>((e) {
    return TestCase.fromJson(e);
  }).toList();

  List<TestCase> leftTestCases = [];

  for (var testCase in testCases) {
    if (testCase.needCheck && testCase.isPassed) {
      // move file to expect folder
      var outputFilePath = '$outputFolder/${testCase.filename}';
      var expectFilePath = '$expectFolder/${testCase.filename}';
      var outputFile = File(outputFilePath);
      outputFile.copySync(expectFilePath);
    } else {
      leftTestCases.add(testCase);
    }
  }
  // write left test cases to json file
  jsonString = JsonEncoder.withIndent('  ').convert(leftTestCases);
  jsonFile.writeAsStringSync(jsonString);

  print("You have ${leftTestCases.length} cases need check.");
}
