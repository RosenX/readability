import 'package:html/dom.dart';

class MetaParser {
  bool isDebug;

  MetaParser({this.isDebug = false});

  String parseTitle(Document htmlDoc) {
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
    if (isDebug) {
      print('title: $title');
    }
    return title;
  }

  String parseAuthor(Document htmlDoc) {
    String author =
        htmlDoc.querySelector('meta[name="author"]')?.attributes['content'] ??
            "";
    if (isDebug) {
      print('author: $author');
    }
    return author;
  }
}
