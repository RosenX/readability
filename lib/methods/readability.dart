import 'dart:collection';
import 'dart:math';

import 'package:html/dom.dart';
import 'package:readability/base/extractor.dart';
import 'package:readability/base/processor.dart';

class Readability implements Extractor {
  final preprocessors = [
    CleanUnusefulTagProcessor(),
    ReplaceDivWithPTagProcessor(),
    TransformATagProcessor(),
  ];

  final int minTextLength;
  bool isDebug;

  Readability({this.minTextLength = 25, this.isDebug = false});

  final postprocessors = [
    FigurePrettyProcessor(),
    RemoveUnusefulAttributeProcessor(),
    RemoveAInHProcessor(),
    RemoveEmptyTagProcessor(),
  ];

  final tagScore = {
    'div': 5,
    'pre': 3,
    'td': 3,
    'blockquote': 3,
    'address': -3,
    'ol': -3,
    'ul': -3,
    'dl': -3,
    'dd': -3,
    'dt': -3,
    'li': -3,
    'form': -3,
    'th': -5,
    'h1': -5,
    'h2': -5,
    'h3': -5,
    'h4': -5,
    'h5': -5,
    'h6': -5,
  };

  final scoreTag = ['p', 'pre', 'td', 'img', 'video'];

  final textTag = ['pre', 'td', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'];

  String cleanText(String text) {
    // Many spaces make the following regexes run forever
    text = text.replaceAll(RegExp(r"\s{255,}"), ' ' * 255);
    text = text.replaceAll(RegExp(r"\s*\n\s*"), '\n');
    text = text.replaceAll(RegExp(r"\n{2,}"), '\n');
    text = text.replaceAll(RegExp(r"\t|[ \t]{2,}"), ' ');
    return text.trim();
  }

  @override
  String extract(Document doc) {
    for (var processor in preprocessors) {
      processor.process(doc);
    }

    Map<Element, double> candidates = _scoreParagraphs(doc);

    Element topCandidate = _selectBestCandidate(candidates);

    // convert Element to Document
    Document html = Document();
    html.append(topCandidate);

    for (var processor in postprocessors) {
      processor.process(html);
    }
    return html.outerHtml;
  }

  /// score nodes in html
  Map<Element, double> _scoreParagraphs(Document doc) {
    Map<Element, double> candidates = HashMap();
    // all element of in textTag
    var allTextTag = doc.querySelectorAll(scoreTag.join(','));
    for (var tag in allTextTag) {
      var parentTag = tag.parent;
      if (parentTag == null) {
        continue;
      }
      var grandParentTag = parentTag.parent;

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

      score += innerText.split(RegExp(r'[，,]')).length;

      candidates[parentTag] = candidates[parentTag]! + score;
      if (grandParentTag != null) {
        candidates[grandParentTag] = candidates[grandParentTag]! + score / 2;
      }

      // iterate the candiate, caculate link density
      // for (var candidate in candidates.keys) {
      //   var links = candidate.querySelectorAll('a');
      //   var text = candidate.text;
      //   var linkLength = 0;
      //   for (var link in links) {
      //     linkLength += link.text.length;
      //   }
      //   var linkDensity = linkLength / text.length;
      //   candidates[candidate] = candidates[candidate]! * (1 - linkDensity);
      // }
    }
    return candidates;
  }

  /// score elem
  double _scoreNode(Element elem) {
    double score = 0;
    score += tagScore[elem.localName] ?? 0;
    return score;
  }

  // choose best candidate
  Element _selectBestCandidate(Map<Element, double> candidates) {
    return candidates.entries
        .reduce(
            (entry1, entry2) => entry1.value > entry2.value ? entry1 : entry2)
        .key;
  }
}
