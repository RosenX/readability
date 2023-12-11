import 'dart:collection';
import 'dart:math';

import 'package:html/dom.dart';
import 'package:readability/src/base/index.dart';

class Readability extends BaseExtractor {
  final int minTextLength;

  Readability({
    this.minTextLength = 25,
    required super.meta,
    super.isDebug = false,
    super.onlyClean = false,
  });

  @override
  List<Processor> get preprocessors => [
        RemoveUnusefulTagProcessor(),
        RemoveUnusefulNodeProcessor(),
        RemoveSuspiciousTagProcessor(),
        RemoveHiddenTagProcessor(),
        FigureTransfomProcessor(),
        ImgSrcReplaceProcessor(),
        ReplaceSectionWithDivProcessor(),
        ExposeTextProcessor(),
        RemoveInvalidATagProcessor(),
        RemoveInvalidImgTagProcessor(),
        HTransformProcessor(),
        ReplaceOPTagProcessor(),
        ReplaceBigStrongWithSpanProcessor(),
        ReplaceInvalidFigureWithDivProcessor(),
        ReplaceDivWithPTagProcessor(),
        FormatHtmlRecurrsivelyProcessor(),
        ExposeLonelyTagInDiv(),
        ExposeDivInDiv(),
        RemoveLastBrProcessor(),
        ImageStyleProcessor(),
        RemoveUnusefulAttributeProcessor(),
      ];

  @override
  List<Processor> get postprocessors => [
        RemoveEmptyTagProcessor(),
      ];

  final scoreTag = ['p', 'td', 'h1', 'h2', 'h3', 'ul', 'pre'];

  final titleTag = ['h1', 'h2'];

  @override
  Element extractContent(Element doc) {
    Map<Element, double> candidates = _scoreParagraphs(doc);

    final topCandidate = _selectBestCandidate(candidates);
    // Element? titleElement = finalTitleElement(doc);
    // Element result = titleElement == null
    //     ? topCandidate
    //     : findCommonAncestor(topCandidate, titleElement);
    return topCandidate;
  }

  /// find common ancestor of two elements
  // Element findCommonAncestor(Element candidate, Element title) {
  //   if (candidate == title) return candidate;
  //   List<Element> titleAncestors = [];
  //   while (title.parent != null) {
  //     titleAncestors.add(title);
  //     title = title.parent!;
  //   }
  //   while (candidate.parent != null) {
  //     if (titleAncestors.contains(candidate)) {
  //       return candidate;
  //     }
  //     candidate = candidate.parent!;
  //   }
  //   return candidate;
  // }

  // Element? finalTitleElement(Document doc) {
  //   if (title == null) return null;
  //   final hTags = doc.querySelectorAll('h1,h2');
  //   Element? bestTag;
  //   double bestScore = 0;
  //   for (var tag in hTags) {
  //     double similarity = titleSimilarityScore(title: title!, hText: tag.text);
  //     if (isDebug) {
  //       print('title: $title, hText: ${tag.text}, score: $similarity');
  //     }
  //     if (similarity > bestScore) {
  //       bestScore = similarity;
  //       bestTag = tag;
  //     }
  //   }
  //   return bestTag;
  // }

  /// score nodes in html
  Map<Element, double> _scoreParagraphs(Element doc) {
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

      score += min(innerTextLen / 100, 3);

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
        logger("step2_score_$score", candidate.outerHtml);
      }
    }
    return topCandidate;
  }

  double titleSimilarityScore({required String title, required String hText}) {
    if (title.isEmpty) return 0;
    int distance = editDistance(title, hText);
    return max(1 - distance / title.length, 0);
  }
}
