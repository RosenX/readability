enum MainContentType { article, video }

class MainContent {
  late String title;
  final String? url;
  late String author;
  late String content;
  final MainContentType type;

  MainContent({
    this.url,
    required this.type,
  });

  String pureHtml() {
    if (!content.contains('<h1') && title.isNotEmpty) {
      content = '<h1>$title</h1>$content';
    }
    return '''
    <html>
      <body>
        $content
      </body>
    </html>
    ''';
  }
}
