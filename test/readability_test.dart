import 'package:readability/readability.dart';
import 'package:test/test.dart';

void main() {
  group('Html document clean test', () {
    // html with script and style
    final html = '''
    <html>
      <head>
        <title>Test</title>
      </head>
      <body>
        <script>console.log('hello world')</script>
        <style>body {color: red;}</style>
        <div>hello world</div>
      </body>
    ''';

    test('First Test', () {
      var doc = HtmlDocument(input: html);
    });
  });
}
