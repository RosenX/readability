import 'package:html/dom.dart';

import 'logger.dart';
import 'processor.dart';

abstract class Extractor {
  Document extract(Document doc);
}

class BaseExtractor with Logger implements Extractor {
  List<Processor> get preprocessors => [];
  List<Processor> get postprocessors => [];

  bool isDebug;
  bool onlyClean;

  final rootTag = ['body', 'div'];
  final punctuation = [
    ',',
    '.',
    '!',
    '?',
    ';',
    ':',
    '，',
    '。',
    '！',
    '？',
    '；',
    '：',
  ];

  BaseExtractor({this.isDebug = false, this.onlyClean = false});

  void preprocess(Document doc) {
    for (var i = 0; i < preprocessors.length; i++) {
      var p = preprocessors[i];
      p.process(doc);
      if (isDebug) {
        logger("step1_preprocess_${i}_${p.name}", doc.outerHtml);
      }
    }
  }

  void postprocess(Document doc) {
    for (var i = 0; i < postprocessors.length; i++) {
      var p = postprocessors[i];
      p.process(doc);
      if (isDebug) {
        logger("step3_postprocess_${i}_${p.name}", doc.outerHtml);
      }
    }
  }

  Document extractContent(Document doc) {
    return doc;
  }

  @override
  Document extract(Document doc) {
    preprocess(doc);
    if (!onlyClean) {
      doc = extractContent(doc);
      if (isDebug) {
        logger("step2_extract", doc.outerHtml);
      }
    }
    postprocess(doc);
    return doc;
  }
}
