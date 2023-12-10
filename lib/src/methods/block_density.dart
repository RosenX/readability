import 'package:html/dom.dart';
import 'package:readability/src/base/index.dart';

class NodeData {
  int _textNotInALength = 0;
  int _textInALength = 0;
  int _aCount = 0;
  int _tagCount = 0;
  int _pCount = 0;
  int _punctuation = 0;
  int _effectiveText = 0;
  bool isLinkUsed = false;

  NodeData();

  void add(NodeData other) {
    _textNotInALength += other._textNotInALength;
    _textInALength += other._textInALength;
    _aCount += other._aCount;
    _tagCount += other._tagCount;
    _pCount += other._pCount;
    _punctuation += other._punctuation;
    _effectiveText += other._effectiveText;
  }

  double get effectiveTextDensity => _effectiveText / (_pCount + 1);
  double get punctuationDensity => _punctuation * 1.0;
}

class BlockDensity extends BaseExtractor {
  final String? title;
  final minLengthOfEffectiveText = 25;

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

  final ignoreTag = ['pre', 'code'];
  final blockTag = ['div', 'p'];

  double computeScore(NodeData stat, List<NodeData> stats) {
    double score = 0;
    double effectiveTextDensityMean =
        getMean(stats.map((e) => e.effectiveTextDensity).toList());
    double effectiveTextDensitySd = getSd(
        stats.map((e) => e.effectiveTextDensity).toList(),
        effectiveTextDensityMean);

    if (score > 0) {
      score += 2 *
          (stat.effectiveTextDensity - effectiveTextDensityMean) /
          effectiveTextDensitySd;
    } else {
      score += 2;
    }

    // if (pDensitySd > 0) {
    //   score += (stat.pDensity - pDensityMean) / pDensitySd;
    // } else {
    //   score += 1;
    // }

    double punctuationDensityMean =
        getMean(stats.map((e) => e.punctuationDensity).toList());
    double punctuationDensitySd = getSd(
        stats.map((e) => e.punctuationDensity).toList(),
        punctuationDensityMean);

    if (punctuationDensitySd > 0) {
      score += (stat.punctuationDensity - punctuationDensityMean) /
          punctuationDensitySd;
    } else {
      score += 1;
    }
    return score;
  }

  @override
  Document extractContent(Document doc) {
    Map<Element, NodeData> stats = {};
    for (var child in doc.children) {
      computeStatData(stats, child);
    }
    Element? bestElem;
    double bestScore = 0;

    for (final entry in stats.entries) {
      if (!rootTag.contains(entry.key.localName)) continue;
      final score = computeScore(entry.value, stats.values.toList());
      if (score > bestScore) {
        bestElem = entry.key;
        bestScore = score;
      }
      if (isDebug) {
        logger('step2_block_density_$score', entry.key.outerHtml);
      }
    }
    if (bestElem == null) return doc;
    return Document.html(bestElem.outerHtml);
  }

  void computeStatData(Map<Element, NodeData> stats, Element elem) {
    for (final child in elem.children) {
      computeStatData(stats, child);
    }
    if (ignoreTag.contains(elem.localName)) return;
    NodeData stat = NodeData();
    int textNotInA = 0;
    int punctuationCount = 0;
    int effectiveText = 0;
    for (final node in elem.nodes) {
      if (node.nodeType == Node.ELEMENT_NODE && stats.containsKey(node)) {
        stat.add(stats[node]!);
      }
      // text in leaf node is text_node
      if (node.nodeType == Node.TEXT_NODE && node.text != null) {
        final cleanedText = cleanText(node.text!);
        if (cleanedText.length > minLengthOfEffectiveText) {
          effectiveText++;
          textNotInA += cleanedText.length;
          punctuationCount += statPunctuation(cleanedText, punctuation);
        }
      }
    }
    stat._textNotInALength += textNotInA;
    stat._punctuation += punctuationCount;
    stat._tagCount++;
    stat._effectiveText += effectiveText;

    if (elem.localName == 'p') {
      stat._pCount++;
    }
    if (elem.localName == 'a') {
      stat._aCount++;
      stat._textInALength = stat._textInALength + stat._textNotInALength;
      stat._textNotInALength = 0;
      stat._effectiveText = 0;
      stat._punctuation = 0;
    }
    stats[elem] = stat;
  }
}
