import 'dart:math';

int editDistance(String str1, String str2) {
  int n = str1.length, m = str2.length;
  if (n == 0) return m;
  if (m == 0) return n;
  List<List<int>> dp = List.generate(n + 1, (i) => List.filled(m + 1, 0));
  for (int i = 0; i <= n; i++) {
    for (int j = 0; j <= m; j++) {
      if (i == 0) {
        dp[i][j] = j;
      } else if (j == 0) {
        dp[i][j] = i;
      } else if (str1[i - 1] == str2[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1];
      } else {
        dp[i][j] = min(dp[i][j - 1], min(dp[i - 1][j], dp[i - 1][j - 1])) + 1;
      }
    }
  }
  return dp[n][m];
}

Map<String, String> styleToMap(String style) {
  Map<String, String> result = {};
  List<String> styles = style.split(';');
  for (var style in styles) {
    if (style.trim().isEmpty) continue;
    List<String> kv = style.split(':');
    if (kv.length != 2) continue;
    result[kv[0].trim()] = kv[1].trim();
  }
  return result;
}

String styleToString(Map<String, String> style) {
  String result = '';
  for (var key in style.keys) {
    result += '$key: ${style[key]};';
  }
  return result;
}

double? parseCssSize(String? sizeStr, {required double relativeBase}) {
  if (sizeStr == null) return null;

  double? size = double.tryParse(sizeStr);
  if (size != null) return size;

  if (sizeStr.endsWith('px')) {
    sizeStr = sizeStr.substring(0, sizeStr.length - 2);
    return double.tryParse(sizeStr);
  } else if (sizeStr.endsWith('rem')) {
    // rem must before em, because rem ends with em
    sizeStr = sizeStr.substring(0, sizeStr.length - 3);
    double? rem = double.tryParse(sizeStr);
    if (rem == null) return null;
    return relativeBase;
  } else if (sizeStr.endsWith('em')) {
    sizeStr = sizeStr.substring(0, sizeStr.length - 2);
    double? em = double.tryParse(sizeStr);
    if (em == null) return null;
    return relativeBase;
  } else {
    return null;
  }
}
