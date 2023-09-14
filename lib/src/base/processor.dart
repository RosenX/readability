import 'package:html/dom.dart';

abstract class Processor {
  String get name;
  void process(Document doc);
}

class CleanUnusefulTagProcessor implements Processor {
  final unUsefulTag = [
    'script',
    'iframe',
    'form',
    'meta',
    'link',
    'nav',
    'style',
    'button',
    'svg',
    'header',
    'footer',
  ];

  @override
  String get name => 'clean_unuseful_tag';

  @override
  void process(Document doc) {
    for (var tag in unUsefulTag) {
      doc.querySelectorAll(tag).forEach((e) => e.remove());
    }
  }
}

class ReplaceH5WithPProcessor implements Processor {
  @override
  String get name => 'replace_h5_with_p';

  @override
  void process(Document doc) {
    doc.querySelectorAll('h5').forEach((e) {
      Element p = Element.tag('p');
      p.children.addAll(e.children);
      e.replaceWith(p);
    });
  }
}

class ReplaceDivWithPTagProcessor implements Processor {
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

  @override
  String get name => 'replace_div_with_p_tag';

  @override
  void process(Document doc) {
    // querySelectorAll return a pre-order traversal of dom tree
    var allDiv = doc.querySelectorAll('div').reversed;
    for (var div in allDiv) {
      var isBlock = false;
      for (var tag in blockTag) {
        if (div.querySelector(tag) != null) {
          isBlock = true;
          break;
        }
      }
      if (!isBlock) {
        Element p = Element.tag('p');
        p.innerHtml = div.innerHtml;
        div.replaceWith(p);
      }
    }
  }
}

class RemoveUnnecessaryNestedDivProcessor implements Processor {
  @override
  String get name => 'remove_unnecessary_nested_div';

  @override
  void process(Document doc) {
    // the order is from leaf to root
    var divs = doc.querySelectorAll('div');
    for (var div in divs) {
      if (div.children.length == 1) {
        if (div.children.first.localName == 'div' ||
            div.children.first.localName == 'p') {
          div.replaceWith(div.children.first);
        }
      }
    }
  }
}

class TransformATagProcessor implements Processor {
  @override
  String get name => 'transform_a_tag';

  @override
  void process(Document doc) {
    // if <a> has no child, but text is empty, try to find 'data-text' in attr
    // case for zhihu article
    doc.querySelectorAll('a').forEach((e) {
      if (e.text.isEmpty) {
        e.text = e.attributes['data-text'] ?? '';
      }
    });
  }
}

class FigurePrettyProcessor implements Processor {
  @override
  String get name => 'figure_pretty';

  @override
  void process(Document doc) {
    var figures = doc.querySelectorAll('figure');
    for (var figure in figures) {
      var noscript = figure.querySelector('noscript');
      if (noscript != null) {
        // create a new figure Element, and put the img in noscript to it
        Element newFigure = Element.tag('figure');
        newFigure.innerHtml = _replaceLtGt(noscript.innerHtml);
        figure.replaceWith(newFigure);
      }
    }
  }

  /// repalce '&lt;' with '<' and '&gt;' with '>'
  String _replaceLtGt(String s) {
    s = s.replaceAll(RegExp(r'&lt;'), '<');
    s = s.replaceAll(RegExp(r'&gt;'), '>');
    return s;
  }
}

class RemoveUnusefulAttributeProcessor implements Processor {
  final attrKeepTag = ['audio'];
  final keepAttr = ['href', 'src'];

  @override
  String get name => 'remove_unuseful_attribute';

  @override
  void process(Document doc) {
    for (var child in doc.children) {
      _removeUnUsefulAttribue(child);
    }
  }

  /// remove all attribute of element except for the attribute in keepAttr
  void _removeUnUsefulAttribue(Element elem) {
    if (attrKeepTag.contains(elem.localName)) {
      return;
    }
    elem.attributes.removeWhere((key, value) => !keepAttr.contains(key));
    for (var child in elem.children) {
      _removeUnUsefulAttribue(child);
    }
  }
}

/// remove parameter int img href
class RemoveImgParameterProcessor implements Processor {
  @override
  String get name => 'remove_img_parameter';

  @override
  void process(Document doc) {
    doc.querySelectorAll('img').forEach((e) {
      var src = e.attributes['src'];
      if (src != null) {
        // split by '?', and get the first part
        e.attributes['src'] = src.split('?').first;
      }
    });
  }
}

class RemoveAInHProcessor implements Processor {
  @override
  String get name => 'remove_a_in_h';

  @override
  void process(Document doc) {
    /// query h1 tag, if there is a <a> tag in h1, remove the <a> tag
    var h1 = doc.querySelector('h1');
    if (h1 != null) {
      h1.querySelector('a')?.remove();
    }
  }
}

class RemoveEmptyTagProcessor implements Processor {
  final textTag = ['pre', 'td', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'li'];
  final blockTag = ['p', 'div', 'section', 'span'];

  @override
  String get name => 'remove_empty_tag';

  @override
  void process(Document doc) {
    // because text tag is nested in p or div tag, so we need to remove text tag first
    for (var child in doc.children) {
      _removeEmptyTextTag(child);
    }
    for (var child in doc.children) {
      _removeEmptyBlockTag(child);
    }
  }

  /// if tag in textTag and its text is empty, remove it
  void _removeEmptyTextTag(Element elem) {
    for (var child in elem.children) {
      _removeEmptyTextTag(child);
    }
    if (textTag.contains(elem.localName) &&
        elem.text.trim().isEmpty &&
        elem.children.isEmpty) {
      elem.remove();
    }
  }

  /// if tag is empty, remove it
  void _removeEmptyBlockTag(Element elem) {
    for (var child in elem.children) {
      _removeEmptyBlockTag(child);
    }
    if (blockTag.contains(elem.localName) &&
        elem.children.isEmpty &&
        elem.text.trim().isEmpty) {
      elem.remove();
    }
    // special case for
    // <block tag> <br> </block tag>
    if (blockTag.contains(elem.localName) &&
        elem.children.length == 1 &&
        elem.text.trim().isEmpty &&
        elem.children.first.localName == 'br') {
      elem.remove();
    }
  }
}

class RemoveInvalidATagProcessor implements Processor {
  @override
  String get name => 'remove_empty_a_tag';

  @override
  void process(Document doc) {
    doc.querySelectorAll('a').forEach((e) {
      if (e.text.trim().isEmpty && e.children.isEmpty) {
        e.remove();
      }
      if (e.attributes['href'] == null) {
        e.remove();
      } else if (!e.attributes['href']!.startsWith('http')) {
        // if href not a url, remove it
        e.remove();
      }
    });
  }
}

class RemoveInvalidImgTagProcessor implements Processor {
  @override
  String get name => 'remove_empty_img_tag';

  @override
  void process(Document doc) {
    doc.querySelectorAll('img').forEach((e) {
      if (e.attributes['src'] == null) {
        e.remove();
      }
      // if src not a url, remove it
      if (!e.attributes['src']!.startsWith('http')) {
        e.remove();
      }
    });
  }
}

/// replace span tag with text in it
class ReplaceSpanTagProcessor implements Processor {
  @override
  String get name => 'replace_span_tag';

  @override
  void process(Document doc) {
    doc.querySelectorAll('span').forEach((e) {
      e.replaceWith(Text(e.text));
    });
  }
}

/// remove invalid figure tag
class RemoveInvalidFigureTagProcessor implements Processor {
  @override
  String get name => 'remove_invalid_figure_tag';

  @override
  void process(Document doc) {
    // if div num in figure is bigger than img num+1, remove figure
    doc.querySelectorAll('figure').forEach((e) {
      var divNum = e.querySelectorAll('div').length;
      var imgNum = e.querySelectorAll('img').length;
      if (divNum > imgNum + 1) {
        e.remove();
      }
    });
  }
}

/// remove tag with suspicious class name like comment, comment-text, comment-content
class RemoveSuspiciousTagProcessor implements Processor {
  final suspiciousClassRegx = RegExp(r'comment');

  @override
  String get name => 'remove_suspicious_tag';

  @override
  void process(Document doc) {
    doc.querySelectorAll('div').forEach((e) {
      if (suspiciousClassRegx.hasMatch(e.className)) {
        e.remove();
      }
    });
    // query all p, is p has no child, and text length is greater than 500, remove it
    doc.querySelectorAll('p').forEach((e) {
      if (e.children.isEmpty && e.text.length > 1000) {
        e.remove();
      }
    });
  }
}
