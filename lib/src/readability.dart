import 'dart:collection';
import 'dart:core';
import 'dart:math';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;

import 'config.dart';
import 'cleaner.dart';

class HtmlDocument {
  String input;
  Pattern? positiveKeywords;
  Pattern? negativeKeywords;
  String? url;
  int minTextLength;
  int retryLength;
  late Document _html;

  late String _content;
  late String _title;
  late String _pureHeml;
  late String _author;

  String get title => _title;
  String get content => _content;
  String get author => _author;
  String get pureHtml => _pureHeml;

  HtmlDocument({
    required this.input,
    this.positiveKeywords,
    this.negativeKeywords,
    this.url,
    this.minTextLength = 25,
    this.retryLength = 250,
  });

  /// clean html document, remove script, style, etc.
  void _cleanUnUsefulTag() {
    for (var tag in unUsefulTag) {
      _html.querySelectorAll(tag).forEach((e) => e.remove());
    }
  }

  /// clean raw text
  String _cleanRaw(String s) {
    // replace all the whitespace with single space
    s.replaceAll(RegExp(r'\s+'), ' ');
    // replace all '&lt;' with '<' and '&gt;' with '>'
    s = s.replaceAll(RegExp(r'&lt;'), '<');
    s = s.replaceAll(RegExp(r'&gt;'), '>');
    return s;
  }

  /// turn Chinese Punctuation marks into English Punctuation marks
  String _turnChinesePunctuationMarks(String s) {
    s = s.replaceAll(RegExp(r'，'), ',');
    s = s.replaceAll(RegExp(r'。'), '.');
    return s;
  }

  /// score nodes in html
  Map<Element, double> _scoreParagraphs() {
    Map<Element, double> candidates = HashMap();
    // all element of in textTag
    var allTextTag = _html.querySelectorAll(textTag.join(','));
    for (var tag in allTextTag) {
      var parentTag = tag.parent;
      if (parentTag == null) {
        continue;
      }
      var grandParentTag = parentTag.parent;
      //TODO put it into beginning
      String innerText = cleanText(tag.text);
      int innerTextLen = innerText.length;

      // If this paragraph is less than 25 characters, don't even count it.
      if (innerTextLen < minTextLength) {
        continue;
      }

      if (!candidates.containsKey(parentTag)) {
        candidates[parentTag] = _scoreNode(parentTag);
      }

      if (grandParentTag != null && !candidates.containsKey(grandParentTag)) {
        candidates[grandParentTag] = _scoreNode(grandParentTag);
      }

      double score = 1;
      // TODO use config
      score += min(innerTextLen / 100, 3);

      score += innerText.split(',').length;

      candidates[parentTag] = candidates[parentTag]! + score;
      if (grandParentTag != null) {
        candidates[grandParentTag] = candidates[grandParentTag]! + score / 2;
      }

      // iterate the candiate, caculate link density
      for (var candidate in candidates.keys) {
        var links = candidate.querySelectorAll('a');
        var text = candidate.text;
        var linkLength = 0;
        for (var link in links) {
          linkLength += link.text.length;
        }
        var linkDensity = linkLength / text.length;
        candidates[candidate] = candidates[candidate]! * (1 - linkDensity);
      }
    }
    return candidates;
  }

  /// score elem
  double _scoreNode(Element elem) {
    double score = 0;
    score += tagScore[elem.localName] ?? 0;
    return score;
  }

  /// replace <div> to <p> if there is no block tag in <div>
  /// traversal the dom tree recursively, if the tag is <div> and all son node dont have block tag, replace it with <p>
  void _replaceDiv() {
    var allDiv = _html.querySelectorAll('div');
    for (var div in allDiv) {
      var isBlock = false;
      for (var tag in blockTag) {
        if (div.querySelector(tag) != null) {
          isBlock = true;
          break;
        }
      }
      if (!isBlock) {
        // TODO check if need to reserve the attribute of div
        Element p = Element.tag('p');
        p.children.addAll(div.children);
        div.replaceWith(p);
      }
    }
  }

  void _getTitle() {
    _title = _html.querySelector('title')?.text ?? "[No Title]";
  }

  void _getAuthor() {
    _author =
        _html.querySelector('meta[name="author"]')?.attributes['content'] ??
            "[No Author]";
  }

  /// produce pure html with title, author, content
  void _producePureHtml() {
    _pureHeml = '''
    <html>
      <head>
        <title>$_title</title>
      </head>
      <body>
        <h1>$_title</h1>
        $_content
      </body>
    </html>
    ''';
  }

  /// main process of the article extraction
  void parse() {
    input = _cleanRaw(input);
    input = _turnChinesePunctuationMarks(input);

    _html = parser.parse(input);

    _getTitle();
    _getAuthor();

    _cleanUnUsefulTag();

    _replaceDiv();

    Map<Element, double> candidates = _scoreParagraphs();

    Element? topCandidate = _selectBestCandidate(candidates);

    if (topCandidate != null) {
      _removeUnUsefulAttribue(topCandidate);
      _removeEmptyTag(topCandidate);
      _content = topCandidate.outerHtml;
    } else {
      _content = "[No Content]";
    }

    _producePureHtml();

    print(_pureHeml);
  }

  /// remove all attribute of element except for the attribute in keepAttr
  void _removeUnUsefulAttribue(Element elem) {
    elem.attributes.removeWhere((key, value) => !keepAttr.contains(key));
    for (var child in elem.children) {
      _removeUnUsefulAttribue(child);
    }
  }

  /// remove empty text tag
  void _removeEmptyTag(Element elem) {
    for (var child in elem.children) {
      if (textTag.contains(child.localName) && child.text.isEmpty) {
        child.remove();
      } else {
        _removeEmptyTag(child);
      }
    }
  }

  // choose best candidate
  Element? _selectBestCandidate(Map<Element, double> candidates) {
    return candidates.entries
        .reduce(
            (entry1, entry2) => entry1.value > entry2.value ? entry1 : entry2)
        .key;
  }
}
