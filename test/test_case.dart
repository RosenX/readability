class TestCase {
  final String filename;
  final bool needCheck;
  final bool isPassed;

  TestCase(
      {required this.filename,
      required this.needCheck,
      required this.isPassed});

  Map<String, dynamic> toJson() =>
      {'filename': filename, 'needCheck': needCheck, 'isPassed': isPassed};

  factory TestCase.fromJson(Map<String, dynamic> json) {
    return TestCase(
        filename: json['filename'],
        needCheck: json['needCheck'],
        isPassed: json['isPassed']);
  }
}
