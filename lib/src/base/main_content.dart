import 'package:html/dom.dart';

enum MainContentType { article, video }

class MainContent {
  late String title;
  final String? url;
  late String author;
  late Document content;
  final MainContentType type;

  MainContent({
    this.url,
    this.type = MainContentType.article,
  });

  String pureHtml() {
    // if first child in content is not h1, and title is not empty, add title to content
    if (content.children.isEmpty) {
      return '';
    }

    if (content.children.first.children.first.localName != 'h1' &&
        title.isNotEmpty) {
      content.children.first.children
          .insert(0, Element.tag('h1')..text = title);
    }

    return '''
    <html>
      <body>
        ${content.outerHtml}
      </body>
    </html>
    ''';
  }
}
