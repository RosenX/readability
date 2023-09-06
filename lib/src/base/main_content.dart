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

  String? pureHtml() {
    if (content.body != null) {
      if (content.body!.children.isEmpty) return null;
      if (content.body!.children.first.localName != 'h1' && hasTitle) {
        content.body!.children.insert(0, Element.tag('h1')..text = title);
      }
      return content.outerHtml;
    }
    return null;
  }
}
