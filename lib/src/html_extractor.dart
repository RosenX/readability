import 'dart:io';

import 'package:html/dom.dart';

import 'package:html/parser.dart' as parser;
import 'package:readability/src/base/main_content.dart';
import 'package:readability/src/methods/meta_parser.dart';
import 'package:readability/src/methods/readability.dart';

import 'base/result.dart';

enum Method { readability }

class HtmlExtractor {
  String rawHtml;
  String? url;
  String? title;
  late Document _htmlDoc;
  late MainContent _mainContent;
  Method method;
  bool isDebug;
  bool onlyClean = false;

  final notSupportTag = ['video', 'math'];

  HtmlExtractor(
      {required this.rawHtml,
      this.url,
      this.title,
      this.method = Method.readability,
      this.onlyClean = false,
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

  HtmlExtractResult? parse() {
    _htmlDoc = parser.parse(rawHtml);

    if (!canParse()) {
      return null;
    }

    _mainContent = MainContent(url: url, title: title);

    // parse meta data like title, author
    var metaParser = MetaParser(isDebug: isDebug);
    metaParser.parse(_mainContent, _htmlDoc);

    switch (method) {
      case Method.readability:
        _mainContent.content =
            Readability(isDebug: isDebug, onlyClean: onlyClean)
                .extract(_htmlDoc);
        break;
      default:
        throw Exception('not support method');
    }

    return _mainContent.pureHtml();
  }

  bool canParse() {
    // if there are not support tag in html, return false;
    for (var tag in notSupportTag) {
      if (_htmlDoc.querySelector(tag) != null) {
        return false;
      }
    }
    return true;
  }
}
