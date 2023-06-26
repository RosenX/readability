import 'package:html/dom.dart';
import 'package:readability/base/main_content.dart';

class MetaParser {
  bool isDebug;

  MetaParser({this.isDebug = false});

  void parse(MainContent content, Document htmlDoc) {
    content.title = _parseTitle(htmlDoc);
    content.author = _parseAuthor(htmlDoc);

    if (isDebug) {
      print('title: ${content.title}');
      print('author: ${content.author}');
    }
  }

  static String _parseTitle(Document htmlDoc) {
    // first get title from meta
    String title = htmlDoc
            .querySelector('meta[property="og:title"]')
            ?.attributes['content'] ??
        '';
    // if title is empty, get title from <title>
    if (title.isEmpty) {
      title = htmlDoc.querySelector('title')?.text ?? '';
    }
    // if title is empty, get title from <h1>
    if (title.isEmpty) {
      title = htmlDoc.querySelector('h1')?.text ?? '';
    }
    return title;
  }

  static String _parseAuthor(Document htmlDoc) {
    String author =
        htmlDoc.querySelector('meta[name="author"]')?.attributes['content'] ??
            "";
    return author;
  }
}
