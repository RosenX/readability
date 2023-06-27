import 'package:html/dom.dart';

import 'logger.dart';
import 'processor.dart';

abstract class Extractor {
  String extract(Document doc);
}

class BaseExtractor with Logger implements Extractor {
  List<Processor> get preprocessors => [];
  List<Processor> get postprocessors => [];

  bool isDebug;

  BaseExtractor({this.isDebug = false});

  void preprocess(Document doc) {
    for (var i = 0; i < preprocessors.length; i++) {
      var p = preprocessors[i];
      p.process(doc);
      if (isDebug) {
        log("preprocess_${i}_${p.name}", doc);
      }
    }
  }

  void postprocess(Document doc) {
    for (var i = 0; i < postprocessors.length; i++) {
      var p = postprocessors[i];
      p.process(doc);
      if (isDebug) {
        log("postprocess_${i}_${p.name}", doc);
      }
    }
  }

  Document extractContent(Document doc) {
    return doc;
  }

  @override
  String extract(Document doc) {
    preprocess(doc);
    extractContent(doc);
    postprocess(doc);
    return doc.outerHtml;
  }
}
