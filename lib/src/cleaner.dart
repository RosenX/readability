import 'dart:core';

final badAttrs = [
  "width",
  "height",
  "style",
  "[-a-z]*color",
  "background[-a-z]*",
  "on*"
];

final singleQuoted = "'[^']+'";
final doubleQuoted = '"[^"]+"';
final nonSpace = '[^ "\'>]+';
final htmlStripRegExp = RegExp(
  '<' // open
  '([^>]+) ' // prefix
  '(?:${badAttrs.join('|')}) *'
  '= *(?:$nonSpace|$singleQuoted|$doubleQuoted)' // undesirable attributes
  '([^>]*)' // value  // postfix
  '>', // end
  caseSensitive: false,
);

// TODO check whether it is right
String cleanAttributes(String html) {
  while (htmlStripRegExp.hasMatch(html)) {
    html = html.replaceAllMapped(htmlStripRegExp, (match) {
      return '<${match.group(1)}${match.group(2)}>';
    });
  }
  return html;
}

String cleanText(String text) {
  // Many spaces make the following regexes run forever
  text = text.replaceAll(RegExp(r"\s{255,}"), ' ' * 255);
  text = text.replaceAll(RegExp(r"\s*\n\s*"), '\n');
  text = text.replaceAll(RegExp(r"\t|[ \t]{2,}"), ' ');
  return text.trim();
}
