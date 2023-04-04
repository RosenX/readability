import 'dart:core';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;

class HtmlDocument {
  String input;
  String? encoding;
  Pattern? positiveKeywords;
  Pattern? negativeKeywords;
  String? url;
  int minTextLength;
  int retryLength;
  bool xpath;
  String handleFailures;

  late Document _html;

  // TODO add more unUsefulTag
  final unUsefulTag = ['script', 'style', 'noscript', 'iframe', 'form'];

  // TODO add more unUsefulAttr
  final unUsefulAttrRegExp = [
    'width',
    'height',
    'style',
    'color*',
  ];

  final regexes = {
    "unlikelyCandidatesRe": RegExp(
        r"combx|comment|community|disqus|extra|foot|header|menu|remark|rss|shoutbox|sidebar|sponsor|ad-break|agegate|pagination|pager|popup|tweet|twitter",
        caseSensitive: false),
    "okMaybeItsACandidateRe":
        RegExp(r"and|article|body|column|main|shadow", caseSensitive: false),
    "positiveRe": RegExp(
        r"article|body|content|entry|hentry|main|page|pagination|post|text|blog|story",
        caseSensitive: false),
    "negativeRe": RegExp(
        r"combx|comment|com-|contact|foot|footer|footnote|masthead|media|meta|outbrain|promo|related|scroll|shoutbox|sidebar|sponsor|shopping|tags|tool|widget",
        caseSensitive: false),
    "divToPElementsRe": RegExp(r"<(a|blockquote|dl|div|img|ol|p|pre|table|ul)",
        caseSensitive: false),
    "videoRe": RegExp(r"https?:\/\/(www\.)?(youtube|vimeo)\.com",
        caseSensitive: false),
  };

  HtmlDocument({
    required this.input,
    this.positiveKeywords,
    this.negativeKeywords,
    this.url,
    this.minTextLength = 25,
    this.retryLength = 250,
    this.xpath = false,
    this.handleFailures = 'discard',
  });

  /// clean html document, remove script, style, etc.
  void _cleanTagRaw() {
    for (var tag in unUsefulTag) {
      _html.querySelectorAll(tag).forEach((e) => e.remove());
    }
  }

  /// clean useless attribute of html document, remove width, height, etc.
  void _cleanAttrRaw() {
    // Traverse all the nodes in the document, remove attribute match the regex in unUsefulAttrRegExp
    _html.querySelectorAll('*').forEach((e) {
      for (var attr in unUsefulAttrRegExp) {
        e.attributes
            .removeWhere((key, value) => RegExp(attr).hasMatch(key as String));
      }
    });
  }

  /// replase sequence of whitespace with single space
  String _replaceWhitespace(String s) {
    s.replaceAll(RegExp(r'\s+'), ' ');
    return s;
  }

  /// XXX get html
  Document get html => _html;

  /// score nodes in html
  void _score() {}

  /// replace <div> to <p> if <div> is misused
  void _replaceDiv() {}

  /// turn input into html document
  void _buildDoc() {}

  /// main process of the article extraction
  void parse() {
    _html = parser.parse(input);
    _cleanTagRaw();
    _cleanAttrRaw();
    _replaceDiv();
    _score();
    _replaceDiv();
    _buildDoc();
  }

  /// Returns the content extract from the html document.
  String? body() {
    return null;
  }

  /// Returns the title of the article.
  String? title() {
    return null;
  }

  /// Returns the author of the article.
  /// If the author is not found, returns null.
  String? author() {
    return null;
  }

  /// Return pure html of the article, include title, author and body extracted from the html document.
  String? summary() {
    return null;
  }
}
