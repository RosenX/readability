import 'package:html/dom.dart';
import 'package:readability/readability.dart';
import 'package:readability/src/base/index.dart';

enum MainContentType { article, video }

class MainContent {
  String? title;
  final String? url;
  String? cover;
  late String author;
  late Document content;
  final MainContentType type;

  bool get hasTitle => title != null && title!.isNotEmpty;

  MainContent({
    this.url,
    this.title,
    this.type = MainContentType.article,
  });

  HtmlExtractResult? pureHtml() {
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
      return HtmlExtractResult(
        content.outerHtml,
        content.body!.text.length,
        cover,
      );
    }
    return null;
  }

  void extractCover() {
    List<Element> imgs = content.querySelectorAll('img');
    imgs.removeWhere((img) => isSmallImage(img));
    if (imgs.isNotEmpty) {
      cover = imgs.first.attributes['src'];
    }
  }

  bool isSmallImage(Element img) {
    // image width and height have been put into style when extract content
    if (img.attributes['style'] == null) return false;
    final styleMap = styleToMap(img.attributes['style']!);
    if (styleMap['width'] != null) {
      if (isSmallSize(styleMap['width']!.trim(), 50)) return true;
    }
    if (styleMap['height'] != null) {
      if (isSmallSize(styleMap['height']!.trim(), 50)) return true;
    }
    return false;
  }
}
