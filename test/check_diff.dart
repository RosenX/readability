import 'dart:convert';
import 'dart:io';

import 'package:html/dom.dart';

import 'test_case.dart';

void compareDom(List<Element> output, List<Element> expect) {
  if (output.length != expect.length) {
    for (var i = 0; i < output.length; i++) {
      var outputElement = output[i];
      print(
          'tag: ${outputElement.localName}, attr: ${outputElement.attributes}');
    }
    print('-------------------');
    for (var i = 0; i < expect.length; i++) {
      var expectElement = expect[i];
      print(
          'tag: ${expectElement.localName}, attr: ${expectElement.attributes}');
    }
    return;
  }
}

void main() async {
  var outputFolder = 'cases_output';
  var expectFolder = 'cases_expect';
  var jsonFile = File('cases_need_check.json');
  String jsonString = await jsonFile.readAsString();

  List<TestCase> testCases = jsonDecode(jsonString).map<TestCase>((e) {
    return TestCase.fromJson(e);
  }).toList();

  for (var testCase in testCases) {
    if (testCase.isNew) {
      continue;
    }
    var outputFilePath = '$outputFolder/${testCase.filename}';
    var expectFilePath = '$expectFolder/${testCase.filename}';

    var outputHtml = File(outputFilePath).readAsStringSync();
    var expectedHtml = File(expectFilePath).readAsStringSync();

    var outputDoc = Document.html(outputHtml);
    var expectedDoc = Document.html(expectedHtml);

    compareDom(outputDoc.children, expectedDoc.children);
  }
}
