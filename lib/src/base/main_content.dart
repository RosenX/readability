import 'package:html/dom.dart';
import 'package:readability/readability.dart';

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

  HtmlResult? pureHtml() {
    if (content.body != null) {
      if (content.body!.children.isEmpty) {
        if (hasTitle) {
          content.body!.children.insert(0, Element.tag('h1')..text = title);
        }
      } else {
        // final h1 = content.body!.querySelector('h1');
        // if (h1 == null && hasTitle) {
        //   content.body!.children.insert(0, Element.tag('h1')..text = title);
        // } else if (h1 != null && hasTitle && h1.text.trim() != title) {
        //   content.body!.children.insert(0, Element.tag('h1')..text = title);
        // }
        final first = content.body!.children.first;
        if (first.localName == 'div') {
          if (first.children.isNotEmpty &&
              first.children.first.localName != 'h1' &&
              hasTitle) {
            first.children.insert(0, Element.tag('h1')..text = title);
          }
        } else if (first.localName != 'h1' && hasTitle) {
          content.body!.children.insert(0, Element.tag('h1')..text = title);
        }
      }
      return HtmlResult(content.outerHtml, content.body!.text.length);
    }
    return null;
  }
}
