import 'dart:core';

String cleanText(String text) {
  // Many spaces make the following regexes run forever
  text = text.replaceAll(RegExp(r"\s{255,}"), ' ' * 255);
  text = text.replaceAll(RegExp(r"\s*\n\s*"), '\n');
  text = text.replaceAll(RegExp(r"\n{2,}"), '\n');
  text = text.replaceAll(RegExp(r"\t|[ \t]{2,}"), ' ');
  return text.trim();
}
