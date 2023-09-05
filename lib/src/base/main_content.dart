import 'package:html/dom.dart';

enum MainContentType { article, video }

class MainContent {
  String? title;
  final String? url;
  late String author;
  late Document content;
  final MainContentType type;

  bool get hasTitle => title != null && title!.isNotEmpty;

  MainContent({
    this.url,
    this.title,
    this.type = MainContentType.article,
  });

  String pureHtml() {
    if (content.body != null) {
      return content.outerHtml;
    }
    // if first child in content is not h1, and title is not empty, add title to content
    if (content.children.isEmpty) {
      return '';
    }

    if (content.children.first.children.first.localName != 'h1' && hasTitle) {
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
