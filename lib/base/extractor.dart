import 'package:html/dom.dart';

abstract class Extractor {
  String extract(Document html);
}
