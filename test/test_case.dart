class TestCase {
  final String filename;
  final bool isNew;
  final bool isPassed;

  TestCase(
      {required this.filename, required this.isNew, required this.isPassed});

  Map<String, dynamic> toJson() =>
      {'filename': filename, 'isNew': isNew, 'isPassed': isPassed};

  factory TestCase.fromJson(Map<String, dynamic> json) {
    return TestCase(
        filename: json['filename'],
        isNew: json['isNew'],
        isPassed: json['isPassed']);
  }
}
