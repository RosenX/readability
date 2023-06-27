import 'dart:io';

import 'package:html/dom.dart';
import 'package:readability/methods/meta_parser.dart';
import 'package:readability/methods/readability.dart';

import 'base/main_content.dart';
import 'package:html/parser.dart' as parser;

enum Method { readability }

class HtmlExtractor {
  String rawHtml;
  String? url;
  late Document _htmlDoc;
  late MainContent _mainContent;
  Method method;
  bool isDebug;

  HtmlExtractor(
      {required this.rawHtml,
      this.url,
      required this.method,
      this.isDebug = false}) {
    if (isDebug) {
      // remove log folder if exists
      var logFolder = Directory('log');
      if (logFolder.existsSync()) {
        logFolder.deleteSync(recursive: true);
      }
      // create log folder
      logFolder.createSync();
      print("url: $url");
    }
  }

  String parse() {
    _htmlDoc = parser.parse(rawHtml);

    var contentType = judgeMainContentType();

    // video type currently not support
    if (contentType == MainContentType.video) {
      return "";
    }

    _mainContent = MainContent(url: url, type: contentType);

    // parse meta data like title, author
    var metaParser = MetaParser(isDebug: isDebug);
    metaParser.parse(_mainContent, _htmlDoc);

    switch (method) {
      case Method.readability:
        _mainContent.content = Readability(isDebug: isDebug).extract(_htmlDoc);
        break;
      default:
        throw Exception('not support method');
    }

    return _mainContent.pureHtml();
  }

  MainContentType judgeMainContentType() {
    var video = _htmlDoc.querySelector('video');
    if (video != null) {
      return MainContentType.video;
    }
    return MainContentType.article;
  }
}
