class HtmlExtractResult {
  String html;
  Meta meta;

  HtmlExtractResult(this.html, this.meta);

  String? get cover => meta.cover;
}

class Meta {
  String? title;
  String? url;
  String? cover;
  String? author;

  Meta({this.title, this.url, this.cover, this.author});

  @override
  String toString() {
    return 'Meta{title: $title, url: $url, cover: $cover, author: $author}';
  }
}
