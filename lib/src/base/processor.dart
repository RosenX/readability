import 'package:html/dom.dart';

abstract class Processor {
  String get name;
  void process(Document doc);
}

class CleanUnusefulTagProcessor implements Processor {
  final unUsefulTag = [
    'script',
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
      p.innerHtml = e.innerHtml;
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

/// remove nested tag only has one child
class RemoveUnnecessaryNestedTagProcessor implements Processor {
  @override
  String get name => 'remove_unnecessary_nested_tag';

  @override
  void process(Document doc) {
    for (var child in doc.children) {
      _replace(child);
    }
  }

  // if tag has one child and the child is the same tag, remove the tag
  void _replace(Element elem) {
    for (var child in elem.children) {
      _replace(child);
    }
    if (elem.children.length == 1 &&
        elem.children.first.localName == elem.localName &&
        elem.text.trim().length == elem.children.first.text.trim().length) {
      elem.replaceWith(elem.children.first);
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
  final attrKeepTag = ['audio', 'video', 'iframe'];
  final keepAttr = ['href', 'src', 'referrerpolicy'];

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

class ReplaceMarkTagProcessor implements Processor {
  @override
  String get name => 'replace_mark_tag';

  @override
  void process(Document doc) {
    doc.querySelectorAll('mark').forEach((e) {
      Element span = Element.tag('span');
      span.innerHtml = e.innerHtml;
      e.replaceWith(span);
    });
  }
}

class ReplaceStrongWithSpanProcessor implements Processor {
  @override
  String get name => 'replace_strong_with_span';

  final maxStrongTextLength = 30;

  @override
  void process(Document doc) {
    // if the length of text in strong tag is more than 30, replace it with span
    doc.querySelectorAll('strong').forEach((e) {
      if (e.text.length > maxStrongTextLength) {
        Element span = Element.tag('span');
        span.innerHtml = e.innerHtml;
        e.replaceWith(span);
      }
    });
  }
}

class RemoveEmptyTagProcessor implements Processor {
  final textTag = [
    'pre',
    'td',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'li',
    'strong',
    'span',
  ];
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
  }
}

class RemoveUnnecessaryBlankLine implements Processor {
  @override
  String get name => 'remove_unnecessary_blank_line';

  @override
  void process(Document doc) {
    for (var child in doc.children) {
      _remove(child);
    }
  }

  /// if tag is empty, remove it
  void _remove(Element elem) {
    for (var child in elem.children) {
      _remove(child);
    }
    if (elem.children.length == 1 &&
        elem.text.trim().isEmpty &&
        elem.children.first.localName == 'br') {
      elem.remove();
    }
  }
}

/// remove continue br tag
class RemoveContinueBrTagProcessor implements Processor {
  @override
  String get name => 'remove_continue_br_tag';

  @override
  void process(Document doc) {
    doc.querySelectorAll('br').forEach((e) {
      var next = e.nextElementSibling;
      if (next != null && next.localName == 'br') {
        next.remove();
      }
    });
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

/// remove last br in block tag
class RemoveLastBrProcessor implements Processor {
  @override
  String get name => 'remove_last_br';

  final blockTag = ['p', 'div', 'section'];

  @override
  void process(Document doc) {
    for (var child in doc.children) {
      remove(child);
    }
  }

  void remove(Element elem) {
    for (var child in elem.children) {
      remove(child);
    }
    if (blockTag.contains(elem.localName)) {
      if (elem.children.isEmpty) {
        return;
      }
      var lastChild = elem.children.last;
      if (lastChild.localName == 'br') {
        lastChild.remove();
      }
    }
  }
}

/// replace <o:p> with p
class ReplaceOPTagProcessor implements Processor {
  @override
  String get name => 'replace_o_p_tag';

  @override
  void process(Document doc) {
    for (var child in doc.children) {
      replace(child);
    }
  }

  void replace(Element elem) {
    for (var child in elem.children) {
      replace(child);
    }
    if (elem.localName == 'o:p') {
      Element p = Element.tag('p');
      p.innerHtml = elem.innerHtml;
      elem.replaceWith(p);
    }
  }
}
