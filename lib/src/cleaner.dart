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

String cleanAttributes(String html) {
  while (htmlStripRegExp.hasMatch(html)) {
    html = html.replaceAllMapped(htmlStripRegExp, (match) {
      return '<${match.group(1)}${match.group(2)}>';
    });
  }
  return html;
}
