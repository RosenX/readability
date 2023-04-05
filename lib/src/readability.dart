import 'dart:collection';
import 'dart:core';
import 'dart:math';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;

import 'config.dart';
import 'cleaner.dart';

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

  late String sumary;

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
            .removeWhere((key, value) => RegExp(attr).hasMatch(key.toString()));
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
      // TODO turn chinese comma into english comma
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
        div.replaceWith(parser.parse('<p>${div.innerHtml}</p>'));
      }
    }
  }

  /// main process of the article extraction
  void parse() {
    _html = parser.parse(input);

    if (_html.body == null) {
      throw Exception('No body tag found in the html document');
    }
    _cleanTagRaw();
    _cleanAttrRaw();
    _replaceDiv();

    Map<Element, double> candidates = _scoreParagraphs();

    Element? topCandidate = selectBestCandidate(candidates);

    if (topCandidate != null) {
      sumary = topCandidate.outerHtml;
    }
  }

  // choose best candidate
  Element? selectBestCandidate(Map<Element, double> candidates) {
    return candidates.entries
        .reduce(
            (entry1, entry2) => entry1.value > entry2.value ? entry1 : entry2)
        .key;
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
    return sumary;
  }
}
