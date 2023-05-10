final unUsefulTag = [
  'script',
  'iframe',
  'form',
  'meta',
  'link',
  'nav',
  'style'
];

final blockTag = [
  'a',
  'blockquote',
  'dl',
  'div',
  'img',
  'ol',
  'p',
  'pre',
  'table',
  'ul',
];

final regexes = {
  "unlikelyCandidatesRe": RegExp(
      r"combx|comment|community|disqus|extra|foot|header|menu|remark|rss|shoutbox|sidebar|sponsor|ad-break|agegate|pagination|pager|popup|tweet|twitter",
      caseSensitive: false),
  "okMaybeItsACandidateRe":
      RegExp(r"and|article|body|column|main|shadow", caseSensitive: false),
  "positiveRe": RegExp(
      r"article|body|content|entry|hentry|main|page|pagination|post|text|blog|story",
      caseSensitive: false),
  "negativeRe": RegExp(
      r"combx|comment|com-|contact|foot|footer|footnote|masthead|media|meta|outbrain|promo|related|scroll|shoutbox|sidebar|sponsor|shopping|tags|tool|widget",
      caseSensitive: false),
  "divToPElementsRe": RegExp(r"<(a|blockquote|dl|div|img|ol|p|pre|table|ul)",
      caseSensitive: false),
  "videoRe":
      RegExp(r"https?:\/\/(www\.)?(youtube|vimeo)\.com", caseSensitive: false),
};

final tagScore = {
  'div': 5,
  'pre': 3,
  'td': 3,
  'blockquote': 3,
  'address': -3,
  'ol': -3,
  'ul': -3,
  'dl': -3,
  'dd': -3,
  'dt': -3,
  'li': -3,
  'form': -3,
  'th': -5,
  'h1': -5,
  'h2': -5,
  'h3': -5,
  'h4': -5,
  'h5': -5,
  'h6': -5,
};

final scoreTag = ['p', 'pre', 'td', 'img', 'video'];

final textTag = ['p', 'pre', 'td'];

final keepAttr = ['href', 'src'];

final attrKeepTag = [];

final notParseTag = ['video'];
