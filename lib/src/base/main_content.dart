import 'dart:math';

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
    imgs.removeWhere((img) {
      if (img.attributes['src'] == null ||
          img.attributes['src']!.isEmpty ||
          !img.attributes['src']!.startsWith('http')) {
        return true;
      }
      return false;
    });

    if (imgs.isEmpty) return;

    Map<Element, (double, int)> imageSize = {};

    for (int i = 0; i < imgs.length; i++) {
      imageSize[imgs[i]] = (imageArea(imgs[i]), i);
    }

    imgs.sort((a, b) {
      final aSize = imageSize[a]!.$1;
      final bSize = imageSize[b]!.$1;
      if (aSize == bSize) {
        return imageSize[a]!.$2.compareTo(imageSize[b]!.$2);
      }
      return bSize.compareTo(aSize);
    });

    cover = imgs.first.attributes['src'];
  }

  double imageArea(Element img) {
    // image width and height have been put into style when extract content
    final double defaultHeight = 800;
    final double defaultWidth = 800;
    final double defaultArea = defaultHeight * defaultWidth;
    if (img.attributes['style'] == null) return defaultArea;
    final styleMap = styleToMap(img.attributes['style']!);
    double? width, height;
    if (styleMap['width'] != null) {
      width = parseCssSize(styleMap['width']!, relativeBase: 25);
    }
    if (styleMap['height'] != null) {
      height = parseCssSize(styleMap['height']!, relativeBase: 25);
    }
    double area = (width ?? defaultWidth) * (height ?? defaultHeight);
    return area > defaultArea ? defaultArea : area;
  }
}
