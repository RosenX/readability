class HtmlExtractResult {
  String html;
  Meta meta;

  HtmlExtractResult(this.html, this.meta);

  String? get cover => meta.cover;
  int get length => html.length;
  bool get hasVideo => meta.hasVideo;
  bool get hasIframe => meta.hasIframe;
  bool get hasAudio => meta.hasAudio;
}

class Meta {
  String? title;
  String? url;
  String? cover;
  String? author;
  bool hasVideo;
  bool hasIframe;
  bool hasAudio;

  Meta({
    this.title,
    this.url,
    this.cover,
    this.author,
    this.hasVideo = false,
    this.hasIframe = false,
    this.hasAudio = false,
  });

  @override
  String toString() {
    return "Meta{title: $title, url: $url, cover: $cover, author: $author, "
        "hasVideo: $hasVideo, hasIframe: $hasIframe, hasAudio: $hasAudio}";
  }
}
