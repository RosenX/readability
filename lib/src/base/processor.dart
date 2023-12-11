import 'package:html/dom.dart';
import 'package:readability/src/base/index.dart';

abstract class Processor {
  String get name;
  void process(Element doc);
}

class RemoveUnusefulTagProcessor implements Processor {
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
  void process(Element doc) {
    for (var tag in unUsefulTag) {
      doc.querySelectorAll(tag).forEach((e) => e.remove());
    }
  }
}

class ReplaceBigHWithDivProcessor implements Processor {
  @override
  String get name => 'replace_big_h_with_div';

  @override
  void process(Element doc) {
    replaceBigHToDiv(doc, 'h1');
    replaceBigHToDiv(doc, 'h2');
    replaceBigHToDiv(doc, 'h3');
    replaceBigHToDiv(doc, 'h4');
    replaceBigHToDiv(doc, 'h5');
    replaceBigHToDiv(doc, 'h6');
  }

  // TODO: 100 is proper?
  void replaceBigHToDiv(Element doc, String tagName) {
    doc.querySelectorAll(tagName).forEach((e) {
      if (e.children.length > 1 || e.text.length > 100) {
        Element div = Element.tag('div');
        div.nodes.addAll(e.nodes);
        e.replaceWith(div);
      }
    });
  }
}

class ReplaceDivWithPTagProcessor implements Processor {
  final blockTag = [
    'blockquote',
    'dl',
    'div',
    'img',
    'ol',
    'p',
    'pre',
    'table',
    'ul',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'iframe',
  ];

  @override
  String get name => 'replace_div_with_p_tag';

  @override
  void process(Element elem) {
    for (var child in elem.children) {
      process(child);
    }
    if (elem.localName != 'div') return;
    bool hasBlock =
        elem.children.any((element) => blockTag.contains(element.localName));
    if (!hasBlock) {
      Element p = Element.tag('p');
      p.nodes.addAll(elem.nodes);
      elem.replaceWith(p);
    }
  }
}

class FigureTransfomProcessor implements Processor {
  @override
  String get name => 'figure_transform';

  @override
  void process(Element elem) {
    var figures = elem.querySelectorAll('figure');
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
  void process(Element doc) {
    doc.querySelectorAll('img').forEach((elem) {
      String? dataSrc = elem.attributes['data-src'];
      if (dataSrc != null && dataSrc.startsWith('http')) {
        elem.attributes['src'] = dataSrc;
      }
    });
  }
}

class RemoveUnusefulAttributeProcessor implements Processor {
  final attrKeepTag = ['audio', 'video', 'iframe'];
  final keepAttr = ['href', 'src', 'referrerpolicy'];

  List<String> get imageKeepAttr => [...keepAttr, 'style'];

  @override
  String get name => 'remove_unuseful_attribute';

  /// remove all attribute of element except for the attribute in keepAttr
  @override
  void process(Element elem) {
    for (var child in elem.children) {
      process(child);
    }
    // if tag is in attrKeepTag, do not remove any attribute
    if (attrKeepTag.contains(elem.localName)) {
      return;
    }
    // remove all attribute except for keepAttr
    if (elem.localName == 'img') {
      elem.attributes.removeWhere((key, value) => !imageKeepAttr.contains(key));
    } else {
      elem.attributes.removeWhere((key, value) => !keepAttr.contains(key));
    }
  }
}

class ImageStyleProcessor implements Processor {
  @override
  String get name => 'image_style';

  List<String> keepAttr = ['width', 'height'];

  @override
  void process(Element doc) {
    doc.querySelectorAll('img').forEach((e) {
      Map<String, String> style = e.attributes['style'] == null
          ? {}
          : styleToMap(e.attributes['style']!);
      if (e.attributes['width'] != null) {
        style['width'] = e.attributes['width']!;
      }
      if (e.attributes['height'] != null) {
        style['height'] = e.attributes['height']!;
      }
      // remove important
      if (style['width'] != null) {
        style['width'] = style['width']!.split(' ')[0];
      }
      if (style['height'] != null) {
        style['height'] = style['height']!.split(' ')[0];
      }
      style.removeWhere((key, value) => !keepAttr.contains(key));
      if (style.isNotEmpty) {
        e.attributes['style'] = styleToString(style);
      } else {
        e.attributes.remove('style');
      }
    });
  }
}

// if really need? yes, to pretty html
class RemoveAInHProcessor implements Processor {
  @override
  String get name => 'remove_a_in_h';

  @override
  void process(Element doc) {
    /// query h1 tag, if there is a <a> tag in h1, remove the <a> tag
    var h1 = doc.querySelector('h1');
    if (h1 != null) {
      h1.querySelectorAll('a').forEach((element) {
        element.remove();
      });
    }
  }
}

class ReplaceBigStrongWithSpanProcessor implements Processor {
  @override
  String get name => 'replace_big_strong_with_span';

  final maxStrongTextLength = 50;

  @override
  void process(Element doc) {
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
    'em'
  ];

  @override
  String get name => 'remove_empty_tag';

  /// if tag in textTag and its text is empty, remove it
  @override
  void process(Element elem) {
    for (var child in elem.children) {
      process(child);
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

  /// if tag is empty, remove it
  @override
  void process(Element elem) {
    for (var child in elem.children) {
      process(child);
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
  void process(Element elem) {
    bool needFormat = true;
    while (needFormat) {
      bool change = false;
      change = change | removeLonelyBr(elem);
      change = change | removeEmptyTag(elem);
      change = change | removeNestedTag(elem);
      needFormat = change;
    }
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

// if need? yes, to flatten text in deep nest
class ExposeLonelyTagInDiv implements Processor {
  @override
  String get name => 'expose_tag';

  final tags = ['p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'];

  @override
  void process(Element elem) {
    for (var child in elem.children) {
      process(child);
    }
    if (elem.localName != 'div') return;
    if (elem.children.length != 1 || elem.nodes.length != 1) return;
    if (!tags.contains(elem.children.first.localName)) return;
    elem.replaceWith(elem.children.first);
  }
}

class ExposeDivInDiv implements Processor {
  @override
  String get name => 'expose_div';

  @override
  void process(Element elem) {
    for (var child in elem.children) {
      process(child);
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
  void process(Element doc) {
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
  void process(Element doc) {
    doc.querySelectorAll('a').forEach((e) {
      if (e.text.trim().isEmpty && e.children.isEmpty) {
        e.remove();
        return;
      }
      if (e.attributes['href'] == null ||
          !e.attributes['href']!.startsWith('http')) {
        e.remove();
      }
    });
  }
}

class RemoveInvalidImgTagProcessor implements Processor {
  @override
  String get name => 'remove_empty_img_tag';

  @override
  void process(Element doc) {
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

/// remove invalid figure tag, which has no img tag
class ReplaceInvalidFigureWithDivProcessor implements Processor {
  @override
  String get name => 'replace_invalid_figure_with_div';

  @override
  void process(Element doc) {
    // if div num in figure is bigger than img num+1, remove figure
    doc.querySelectorAll('figure').forEach((figure) {
      var imgNum = figure.querySelectorAll('img').length;
      if (imgNum == 0) {
        // replace figure with div
        Element div = Element.tag('div');
        div.nodes.addAll(figure.nodes);
        figure.replaceWith(div);
      }
    });
  }
}

/// remove tag with suspicious class name like comment, comment-text, comment-content
class RemoveSuspiciousTagProcessor implements Processor {
  final suspiciousClassRegx = RegExp(
    r'comment|footer|recommend|discuss|sidebar',
    caseSensitive: false,
  );

  @override
  String get name => 'remove_suspicious_tag';

  @override
  void process(Element doc) {
    doc.querySelectorAll('div').forEach((e) {
      if (suspiciousClassRegx.hasMatch(e.className)) {
        e.remove();
      }
      if (suspiciousClassRegx.hasMatch(e.id)) {
        e.remove();
      }
    });
  }
}

/// remove hidden tag
class RemoveHiddenTagProcessor implements Processor {
  @override
  String get name => 'remove_hidden_tag';

  @override
  void process(Element elem) {
    for (var child in elem.children) {
      process(child);
    }
    if (elem.attributes['style'] == null) return;
    var style = styleToMap(elem.attributes['style']!);
    if (style['display'] == 'none' || style['visibility'] == 'hidden') {
      elem.remove();
    }
  }
}

class RemoveLastBrProcessor implements Processor {
  @override
  String get name => 'remove_last_br';

  final blockTag = ['p', 'div'];

  @override
  void process(Element elem) {
    for (var child in elem.children) {
      process(child);
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

// if need? yes, to clean html
class ExposeTextProcessor implements Processor {
  @override
  String get name => 'expose_text';

  final tag = ['span', 'mark'];

  @override
  void process(Element elem) {
    for (var child in elem.children) {
      process(child);
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
  void process(Element doc) {
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
  void process(Element elem) {
    for (var child in elem.children) {
      process(child);
    }
    if (elem.localName == 'o:p') {
      Element p = Element.tag('p');
      p.nodes.addAll(elem.nodes);
      elem.replaceWith(p);
    }
  }
}
