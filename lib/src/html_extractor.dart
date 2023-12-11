import 'dart:io';

import 'package:html/dom.dart';

import 'package:readability/src/base/types.dart';
import 'package:readability/src/methods/index.dart';

enum Method {
  readability,
  readabilityV2,
}

class HtmlExtractor {
  String html;
  String? url;
  String? title;
  Method method;
  bool isDebug;
  bool onlyClean = false;

  HtmlExtractor({
    required this.html,
    this.url,
    this.title,
    this.method = Method.readability,
    this.onlyClean = false,
    this.isDebug = false,
  }) {
    if (isDebug) {
      // remove log folder if exists
      var logFolder = Directory('log');
      if (logFolder.existsSync()) {
        logFolder.deleteSync(recursive: true);
      }
      // create log folder
      logFolder.createSync();
    }
  }

  HtmlExtractResult? parse() {
    Document htmlDoc = Document.html(html);

    if (htmlDoc.body == null) return null;

    Meta meta = parseMeta(htmlDoc);

    late Element mainContent;

    switch (method) {
      case Method.readability:
        mainContent = Readability(
          isDebug: isDebug,
          onlyClean: onlyClean,
          meta: meta,
        ).extract(htmlDoc.body!);
        break;
      case Method.readabilityV2:
        mainContent = ReadabilityV2(
          isDebug: isDebug,
          onlyClean: onlyClean,
          meta: meta,
        ).extract(htmlDoc.body!);
      default:
        throw Exception('not support method');
    }

    if (isDebug) {
      print(meta);
    }

    return HtmlExtractResult(mainContent.outerHtml, meta);
  }

  Meta parseMeta(Document htmlDoc) {
    Meta metaData = Meta();

    // parse meta data like title, author
    var metaParser = MetaParser(isDebug: isDebug);
    if (title == null) {
      metaData.title = metaParser.parseTitle(htmlDoc);
    }
    metaData.author = metaParser.parseAuthor(htmlDoc);
    return metaData;
  }
}
