import 'package:html/dom.dart';
import 'package:readability/src/base/types.dart';

import 'logger.dart';
import 'processor.dart';

abstract class Extractor {
  Element extract(Element doc);
}

class BaseExtractor with Logger implements Extractor {
  List<Processor> get preprocessors => [];
  List<Processor> get postprocessors => [];

  bool isDebug;
  bool onlyClean;
  Meta meta;

  final rootTag = ['body', 'div'];

  BaseExtractor({
    this.isDebug = false,
    this.onlyClean = false,
    required this.meta,
  });

  void preprocess(Element doc) {
    for (var i = 0; i < preprocessors.length; i++) {
      var p = preprocessors[i];
      p.process(doc, meta: meta);
      if (isDebug) {
        logger("step1_preprocess_${i}_${p.name}", doc.outerHtml);
      }
    }
  }

  void postprocess(Element doc) {
    for (var i = 0; i < postprocessors.length; i++) {
      var p = postprocessors[i];
      p.process(doc, meta: meta);
      if (isDebug) {
        logger("step3_postprocess_${i}_${p.name}", doc.outerHtml);
      }
    }
  }

  Element extractContent(Element doc) {
    return doc;
  }

  @override
  Element extract(Element doc) {
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
