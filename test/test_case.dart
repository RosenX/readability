import 'dart:convert';
import 'dart:io';

class TestCase {
  final String output;
  final String expect;
  final bool isNew;

  TestCase({
    required this.output,
    required this.expect,
    required this.isNew,
  });

  Map<String, dynamic> toJson() {
    return {
      'output': output,
      'expect': expect,
      'isNew': isNew,
    };
  }

  factory TestCase.fromJson(Map<String, dynamic> json) {
    return TestCase(
      output: json['output'],
      expect: json['expect'],
      isNew: json['isNew'],
    );
  }
}

void saveTestCases(List<TestCase> cases) {
  String jsonString = JsonEncoder.withIndent('  ').convert(cases);

  // write cases need check to json file
  final jsonFile = File('cases_need_check.json');
  jsonFile.writeAsStringSync(jsonString);
}
