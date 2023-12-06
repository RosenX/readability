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
