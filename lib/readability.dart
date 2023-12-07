/// Support for doing something awesome.
///
/// More dartdocs go here.
library readability;

export 'src/html_extractor.dart';

class HtmlExtractResult {
  String html;
  int contentLength;
  String? cover;

  HtmlExtractResult(this.html, this.contentLength, this.cover);
}



// TODO: Export any libraries intended for clients of this package.
