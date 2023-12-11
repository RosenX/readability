import 'dart:math';
import 'package:html/dom.dart';
import 'package:readability/src/base/index.dart';

class ScoreData {
  int textLength = 0;
  int sentanceCount = 0;
  double score = 0;

  ScoreData();

  void add(ScoreData other) {
    textLength += other.textLength;
    sentanceCount += other.sentanceCount;
  }
}

class BlockDensity extends BaseExtractor {
  final String? title;
  final minLengthOfEffectiveText = 20;
  final minLengthOfValidText = 5;
  final brotherMergeScoreRatio = 0.3;
  final updateScoreRatio = 0.5;

  BlockDensity({
    this.title,
    super.isDebug = false,
    super.onlyClean = false,
  });

  @override
  List<Processor> get preprocessors => [
        RemoveUnusefulTagProcessor(),
        RemoveUnusefulNodeProcessor(),
        RemoveSuspiciousTagProcessor(),
        RemoveHiddenTagProcessor(),
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

  final scoreTag = ['p', 'td', 'ul', 'pre', 'ol'];
  final titleTag = ['h1', 'h2'];
  final ignoreTag = ['a', 'img'];
  final blockTag = ['div', 'body'];

  @override
  Document extractContent(Document doc) {
    Map<Element, ScoreData> scoreData = {};
    for (var child in doc.children) {
      computeStatData(scoreData, child);
    }
    Element? bestElem;
    double bestScore = 0;

    for (final entry in scoreData.entries) {
      if (!rootTag.contains(entry.key.localName)) continue;
      final score = entry.value.score;
      if (score > bestScore) {
        bestElem = entry.key;
        bestScore = score;
      }
      if (isDebug) {
        logger('step2_block_density_$score', entry.key.outerHtml);
      }
    }
    if (bestElem == null) return doc;
    Element result =
        mergeBrothers(scoreData, bestElem, brotherMergeScoreRatio * bestScore);
    return Document.html(result.outerHtml);
  }

  Element mergeBrothers(
    Map<Element, ScoreData> scoreDatas,
    Element element,
    double threshold,
  ) {
    Element? parent = element.parent;
    if (parent == null) return element;
    List<Element> children = parent.children;
    int left = children.length - 1, right = 0;
    for (int i = 0; i < children.length; i++) {
      if (!scoreDatas.containsKey(children[i])) continue;
      double score = scoreDatas[children[i]]!.score;
      if (score > threshold) {
        left = min(left, i);
        right = max(right, i);
      }
    }
    if (left == right) return element;
    for (int i = 0; i < children.length; i++) {
      if (i < left || i > right) {
        children[i].remove();
      }
    }
    return parent;
  }

  void computeStatData(Map<Element, ScoreData> scoreDatas, Element elem) {
    for (final child in elem.children) {
      computeStatData(scoreDatas, child);
    }
    if (ignoreTag.contains(elem.localName)) return;
    ScoreData scoreData = ScoreData();

    if (blockTag.contains(elem.localName)) {
      for (final child in elem.children) {
        scoreData.score += (scoreDatas[child]?.score ?? 0) * updateScoreRatio;
      }
      scoreDatas[elem] = scoreData;
      return;
    }

    for (final node in elem.nodes) {
      if (node.nodeType == Node.ELEMENT_NODE && scoreDatas.containsKey(node)) {
        scoreData.add(scoreDatas[node]!);
      }
      if (node.nodeType == Node.TEXT_NODE && node.text != null) {
        String text = cleanText(node.text!);
        if (text.length < minLengthOfValidText) continue;
        scoreData.sentanceCount += text.split(RegExp(r'[，,]')).length;
        scoreData.textLength += text.length;
      }
    }

    if (scoreTag.contains(elem.localName) &&
        scoreData.textLength > minLengthOfEffectiveText) {
      scoreData.score +=
          min(scoreData.textLength / 100, 3) + scoreData.sentanceCount;
    }
    if (isDebug) {
      print("$elem, ${scoreData.score}");
    }
    scoreDatas[elem] = scoreData;
  }
}
