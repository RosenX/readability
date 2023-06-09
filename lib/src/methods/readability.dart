import 'dart:collection';
import 'dart:math';

import 'package:html/dom.dart';
import 'package:readability/src/base/extractor.dart';
import 'package:readability/src/base/processor.dart';

class Readability extends BaseExtractor {
  final int minTextLength;

  Readability({this.minTextLength = 25, super.isDebug = false});

  @override
  List<Processor> get preprocessors => [
        CleanUnusefulTagProcessor(),
        RemoveSuspiciousTagProcessor(),
        ReplaceDivWithPTagProcessor(),
        TransformATagProcessor(),
        RemoveAInHProcessor(),
        RemoveInvalidATagProcessor(),
        RemoveInvalidImgTagProcessor(),
        RemoveUnnecessaryNestedDivProcessor(),
        RemoveEmptyTagProcessor(),
        FigurePrettyProcessor(),
        RemoveUnusefulAttributeProcessor(),
        RemoveInvalidFigureTagProcessor(),
      ];

  @override
  List<Processor> get postprocessors => [
        RemoveImgParameterProcessor(),
      ];

  final scoreTag = [
    'p',
    'pre',
    'td',
    'img',
    'video',
    'pre',
    'td',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'ul'
  ];

  String cleanText(String text) {
    // Many spaces make the following regexes run forever
    text = text.replaceAll(RegExp(r"\s{255,}"), ' ' * 255);
    text = text.replaceAll(RegExp(r"\s*\n\s*"), '\n');
    text = text.replaceAll(RegExp(r"\n{2,}"), '\n');
    text = text.replaceAll(RegExp(r"\t|[ \t]{2,}"), ' ');
    return text.trim();
  }

  @override
  Document extractContent(Document doc) {
    Map<Element, double> candidates = _scoreParagraphs(doc);

    Element topCandidate = _selectBestCandidate(candidates);

    // convert Element to Document
    Document html = Document();
    html.append(topCandidate);
    return html;
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
        candidates[parentTag] = 0;
      }

      if (grandParentTag != null && !candidates.containsKey(grandParentTag)) {
        candidates[grandParentTag] = 0;
      }

      double score = 1;

      score += min(innerTextLen / 100, 3);

      score += innerText.split(RegExp(r'[，,]')).length;

      candidates[parentTag] = candidates[parentTag]! + score;
      if (grandParentTag != null) {
        candidates[grandParentTag] = candidates[grandParentTag]! + score * 0.6;
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

  // choose best candidate
  Element _selectBestCandidate(Map<Element, double> candidates) {
    return candidates.entries
        .reduce(
            (entry1, entry2) => entry1.value > entry2.value ? entry1 : entry2)
        .key;
  }
}
