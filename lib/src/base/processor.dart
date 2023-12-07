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

class ReplaceUnnecessaryProcessor implements Processor {
  @override
  String get name => 'replace_unnecessary_h';

  @override
  void process(Document doc) {
    replaceBigHToDiv(doc, 'h1');
    replaceBigHToDiv(doc, 'h2');
    replaceBigHToDiv(doc, 'h3');
    replaceBigHToDiv(doc, 'h4');
    replaceBigHToDiv(doc, 'h5');
    replaceBigHToDiv(doc, 'h6');
  }

  void replaceBigHToDiv(Document doc, String tagName) {
    doc.querySelectorAll(tagName).forEach((e) {
      if (e.children.length > 1 || e.text.length > 100) {
        Element div = Element.tag('div');
        div.nodes.addAll(e.nodes);
        e.replaceWith(div);
      }
    });
  }

  void replaceHToP(Document doc, String tagName) {
    doc.querySelectorAll(tagName).forEach((e) {
      Element p = Element.tag('p');
      p.nodes.addAll(e.nodes);
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
        p.nodes.addAll(div.nodes);
        div.replaceWith(p);
      }
    }
  }
}

/// remove nested tag only has one child
class RemoveNestedTagProcessor implements Processor {
  @override
  String get name => 'remove_nested_tag';

  @override
  void process(Document doc) {
    for (var child in doc.children) {
      remove(child);
    }
  }

  // if tag has one child and the child is the same tag, remove the tag
  void remove(Element elem) {
    for (var child in elem.children) {
      remove(child);
    }
    if (elem.children.length == 1 &&
        elem.children.first.localName == elem.localName &&
        elem.text.trim().length == elem.children.first.text.trim().length) {
      elem.replaceWith(elem.children.first);
    }
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
        // newFigure.nodes.addAll(noscript.nodes);
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

class ImgSrcReplaceProcessor implements Processor {
  @override
  String get name => 'img_src_replace';

  @override
  void process(Document doc) {
    doc.querySelectorAll('img').forEach((e) {
      String? dataSrc = e.attributes['data-src'];
      if (dataSrc != null && dataSrc.startsWith('http')) {
        e.attributes['src'] = dataSrc;
      }
    });
  }
}

class RemoveUnusefulAttributeProcessor implements Processor {
  final attrKeepTag = ['audio', 'video', 'iframe'];
  final keepAttr = ['href', 'src', 'referrerpolicy', 'style'];
  final keepStyle = ['width', 'height'];

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
    // remove all style except for keepStyle
    if (elem.localName == 'img' && elem.attributes['style'] != null) {
      var style = elem.attributes['style']!;
      var styleList = style.split(';');
      var newStyleList = styleList.where((e) {
        var kv = e.split(':');
        if (kv.length != 2 || kv[1].trim().endsWith('%')) {
          return false;
        }
        return keepStyle.contains(kv[0].trim());
      });
      if (newStyleList.isEmpty) {
        elem.attributes.remove('style');
      } else {
        elem.attributes['style'] = newStyleList.join(';');
      }
    } else {
      elem.attributes.remove('style');
    }
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
      h1.querySelectorAll('a').forEach((element) {
        element.remove();
      });
    }
  }
}

class ReplaceStrongWithSpanProcessor implements Processor {
  @override
  String get name => 'replace_strong_with_span';

  final maxStrongTextLength = 50;

  @override
  void process(Document doc) {
    // if the length of text in strong tag is more than 30, replace it with span
    doc.querySelectorAll('strong').forEach((e) {
      if (e.text.length > maxStrongTextLength) {
        Element span = Element.tag('span');
        span.nodes.addAll(e.nodes);
        e.replaceWith(span);
      }
    });
  }
}

class RemoveEmptyTagProcessor implements Processor {
  final tags = [
    'pre',
    'td',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'li',
    'ul',
    'strong',
    'span',
    'div',
    'p',
    'section',
    'span',
    'blockquote',
    'i',
  ];

  @override
  String get name => 'remove_empty_tag';

  @override
  void process(Document doc) {
    // because text tag is nested in p or div tag, so we need to remove text tag first
    for (var child in doc.children) {
      remove(child);
    }
  }

  /// if tag in textTag and its text is empty, remove it
  void remove(Element elem) {
    for (var child in elem.children) {
      remove(child);
    }
    if (tags.contains(elem.localName) &&
        elem.text.trim().isEmpty &&
        elem.children.isEmpty) {
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
      remove(child);
    }
  }

  /// if tag is empty, remove it
  void remove(Element elem) {
    for (var child in elem.children) {
      remove(child);
    }
    if (elem.children.length == 1 &&
        elem.text.trim().isEmpty &&
        elem.children.first.localName == 'br') {
      elem.remove();
    }
  }
}

class FormatHtmlRecurrsivelyProcessor implements Processor {
  @override
  String get name => 'format_html_recurrsively';

  final tags = [
    'pre',
    'td',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'li',
    'ul',
    'strong',
    'span',
    'div',
    'p',
    'section',
    'span',
    'blockquote',
    'i',
  ];

  @override
  void process(Document doc) {
    bool needFormat = true;
    while (needFormat) {
      needFormat = format(doc);
    }
  }

  bool format(Document doc) {
    bool change = false;
    for (var child in doc.children) {
      change = change | removeLonelyBr(child);
      change = change | removeEmptyTag(child);
      change = change | removeNestedTag(child);
    }
    return change;
  }

  bool removeLonelyBr(Element elem) {
    bool change = false;
    for (var child in elem.children) {
      change = change | removeLonelyBr(child);
    }
    if (elem.children.length == 1 &&
        elem.text.trim().isEmpty &&
        elem.children.first.localName == 'br') {
      elem.remove();
      change = true;
    }
    return change;
  }

  bool removeEmptyTag(Element elem) {
    bool change = false;
    for (var child in elem.children) {
      change = change | removeEmptyTag(child);
    }
    if (tags.contains(elem.localName) &&
        elem.text.trim().isEmpty &&
        elem.children.isEmpty) {
      elem.remove();
      change = true;
    }
    return change;
  }

  bool removeNestedTag(Element elem) {
    bool change = false;
    for (var child in elem.children) {
      change = change | removeNestedTag(child);
    }
    if (elem.children.length == 1 &&
        elem.children.first.localName == elem.localName &&
        elem.text.trim().length == elem.children.first.text.trim().length) {
      elem.replaceWith(elem.children.first);
      change = true;
    }
    return change;
  }
}

class ExposeTagInDiv implements Processor {
  @override
  String get name => 'expose_tag';

  final tags = ['p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'];

  @override
  void process(Document doc) {
    for (var child in doc.children) {
      expose(child);
    }
  }

  void expose(Element elem) {
    for (var child in elem.children) {
      expose(child);
    }
    if (elem.localName != 'div') return;
    if (elem.children.length != 1 || elem.nodes.length != 1) return;
    if (!tags.contains(elem.children.first.localName)) return;
    elem.replaceWith(elem.children.first);
  }
}

class ExposeDiv implements Processor {
  @override
  String get name => 'expose_div';

  @override
  void process(Document doc) {
    for (var child in doc.children) {
      expose(child);
    }
  }

  void expose(Element elem) {
    for (var child in elem.children) {
      expose(child);
    }
    if (elem.localName != 'div') return;
    final parent = elem.parent;
    if (parent == null) return;
    // some are text node
    if (elem.children.length != elem.nodes.length) return;
    bool isAllDiv =
        elem.children.every((element) => element.localName == 'div');
    if (!isAllDiv) return;
    int index = parent.nodes.indexOf(elem);
    parent.nodes.replaceRange(index, index + 1, elem.nodes);
  }
}

class RemoveUnusefulNodeProcessor implements Processor {
  @override
  String get name => 'remove_empty_text_node';

  @override
  void process(Document doc) {
    for (var node in doc.nodes) {
      remove(node);
    }
  }

  void remove(Node node) {
    for (var node in node.nodes) {
      remove(node);
    }
    List<Node> newSubNodes = [];
    for (var node in node.nodes) {
      if (node.nodeType == Node.COMMENT_NODE) {
        continue;
      }
      if (node.nodeType != Node.TEXT_NODE) {
        newSubNodes.add(node);
        continue;
      }
      if (node.text == null || node.text!.trim().isEmpty) {
        continue;
      }
      newSubNodes.add(node);
    }
    node.nodes.clear();
    node.nodes.addAll(newSubNodes);
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
        return;
      }
      if (e.attributes['href'] == null ||
          !e.attributes['href']!.startsWith('http')) {
        if (e.children.isEmpty) {
          e.remove();
        }
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

/// TODO: why
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
  final suspiciousClassRegx = RegExp(
    r'comment|footer|recommend|discuss',
    caseSensitive: false,
  );

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
      Node lastNode = elem.nodes.last;
      if (lastChild.localName == 'br' && lastNode == lastChild) {
        lastChild.remove();
      }
    }
  }
}

/// expose text in tags
class ExposeTextProcessor implements Processor {
  @override
  String get name => 'expose_text';

  final tag = ['span', 'mark'];

  @override
  void process(Document doc) {
    for (var child in doc.children) {
      expose(child);
    }
  }

  void expose(Element elem) {
    for (var child in elem.children) {
      expose(child);
    }
    if (!tag.contains(elem.localName)) return;
    if (elem.children.isNotEmpty) return;
    Element? parentTag = elem.parent;
    if (parentTag == null) return;
    for (var node in parentTag.nodes) {
      if (node == elem) {
        node.replaceWith(Text(node.text));
      }
    }
  }
}

/// replace section tag with div
class ReplaceSectionWithDivProcessor implements Processor {
  @override
  String get name => 'replace_section_tag';

  @override
  void process(Document doc) {
    doc.querySelectorAll('section').forEach((e) {
      Element div = Element.tag('div');
      div.nodes.addAll(e.nodes);
      e.replaceWith(div);
    });
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
      p.nodes.addAll(elem.nodes);
      elem.replaceWith(p);
    }
  }
}

/// change video to iframe
// class ReplaceVideoWithIframeProcessor implements Processor {
//   @override
//   String get name => 'replace_video_with_iframe';

//   @override
//   void process(Document doc) {
//     doc.querySelectorAll('video').forEach((e) {
//       Element iframe = Element.tag('iframe');
//       for (var child in e.children) {
//         if (child.localName == 'source' && child.attributes['src'] != null) {
//           iframe.attributes['src'] = child.attributes['src']!;
//           break;
//         }
//       }
//       iframe.attributes['allowfullscreen'] = 'true';
//       if (iframe.attributes['src'] != null) {
//         e.replaceWith(iframe);
//       }
//     });
//   }
// }
