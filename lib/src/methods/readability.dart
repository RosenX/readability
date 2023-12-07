import 'dart:collection';
import 'dart:math';

import 'package:html/dom.dart';
import 'package:readability/src/base/extractor.dart';
import 'package:readability/src/base/index.dart';
import 'package:readability/src/base/processor.dart';

class Readability extends BaseExtractor {
  final int minTextLength;
  final String? title;

  Readability({
    this.minTextLength = 25,
    this.title,
    super.isDebug = false,
    super.onlyClean = false,
  });

  @override
  List<Processor> get preprocessors => [
        CleanUnusefulTagProcessor(),
        RemoveUnusefulNodeProcessor(),
        RemoveSuspiciousTagProcessor(),
        FigurePrettyProcessor(),
        ImgSrcReplaceProcessor(),
        ReplaceSectionWithDivProcessor(),
        ExposeTextProcessor(),
        RemoveAInHProcessor(),
        RemoveInvalidATagProcessor(),
        RemoveInvalidImgTagProcessor(),
        ReplaceUnnecessaryProcessor(),
        ReplaceOPTagProcessor(),
        ReplaceStrongWithSpanProcessor(),
        RemoveInvalidFigureTagProcessor(),
        ReplaceDivWithPTagProcessor(),
        FormatHtmlRecurrsivelyProcessor(),
        ExposeTagInDiv(),
        RemoveLastBrProcessor(),
        RemoveUnusefulAttributeProcessor(),
      ];

  @override
  List<Processor> get postprocessors => [
        RemoveEmptyTagProcessor(),
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
    'ul',
  ];

  final rootTag = ['body', 'div', 'section'];
  final titleTag = ['h1', 'h2'];

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

    final topCandidate = _selectBestCandidate(candidates);

    // convert Element to Document
    Document html = Document.html(topCandidate.outerHtml);
    // html.append(topCandidate);
    return html;
  }

  Map<Element, double> _extraScore(
    Document doc,
    Map<Element, double> candidates,
  ) {
    if (title == null) return candidates;
    final hTags = doc.querySelectorAll('h1,h2');
    for (var tag in hTags) {
      final parentTag = tag.parent;
      final grandParentTag = parentTag?.parent;
      if (parentTag == null) continue;

      double similarity = titleSimilarityScore(title: title!, hText: tag.text);
      if (isDebug) {
        print('title: $title, hText: ${tag.text}, score: $similarity');
      }
      final score = similarity * 50;
      candidates[parentTag] = candidates[parentTag]! + score;
      if (grandParentTag != null && candidates.containsKey(grandParentTag)) {
        candidates[grandParentTag] = candidates[grandParentTag]! + score * 0.5;
      }
    }
    return candidates;
  }

  /// score nodes in html
  Map<Element, double> _scoreParagraphs(Document doc) {
    Map<Element, double> candidates = HashMap();
    // all element of in textTag
    var allTextTag = doc.querySelectorAll(scoreTag.join(','));
    for (var tag in allTextTag) {
      var parentTag = tag.parent;
      if (parentTag == null) continue;

      var grandParentTag = parentTag.parent;

      String innerText = cleanText(tag.text);
      int innerTextLen = innerText.length;

      if (innerTextLen < minTextLength && !titleTag.contains(tag.localName)) {
        continue;
      }

      if (!candidates.containsKey(parentTag)) {
        candidates[parentTag] = 0;
      }

      if (grandParentTag != null && !candidates.containsKey(grandParentTag)) {
        candidates[grandParentTag] = 0;
      }

      double score = 1;

      score += min(innerTextLen, 3);

      score += innerText.split(RegExp(r'[，,]')).length;

      candidates[parentTag] = candidates[parentTag]! + score;
      if (grandParentTag != null) {
        candidates[grandParentTag] = candidates[grandParentTag]! + score * 0.5;
      }
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
    return candidates;
  }

  // choose best candidate
  Element _selectBestCandidate(Map<Element, double> candidates) {
    double maxScore = 0;
    Element topCandidate = candidates.keys.first;
    for (var candidate in candidates.keys) {
      if (!rootTag.contains(candidate.localName)) {
        continue;
      }
      var score = candidates[candidate]!;
      if (score > maxScore) {
        maxScore = score;
        topCandidate = candidate;
      }
      if (isDebug) {
        this.log("step2_score_$score", candidate.outerHtml);
      }
    }
    return topCandidate;
  }

  double titleSimilarityScore({required String title, required String hText}) {
    int distance = editDistance(title, hText);
    return max(1 - distance / max(title.length, hText.length), 0);
  }
}
