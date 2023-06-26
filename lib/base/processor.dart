import 'package:html/dom.dart';

abstract class Processor {
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
    'style'
  ];
  @override
  void process(Document doc) {
    for (var tag in unUsefulTag) {
      doc.querySelectorAll(tag).forEach((e) => e.remove());
    }
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
        p.children.addAll(div.children);
        div.replaceWith(p);
      }
    }
  }
}

class TransformATagProcessor implements Processor {
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
  void process(Document doc) {
    /// query h1 tag, if there is a <a> tag in h1, remove the <a> tag
    var h1 = doc.querySelector('h1');
    if (h1 != null) {
      h1.querySelector('a')?.remove();
    }
  }
}

class RemoveEmptyTagProcessor implements Processor {
  final textTag = ['pre', 'td', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'];
  @override
  void process(Document doc) {
    for (var child in doc.children) {
      _removeEmptyTag(child);
    }
  }

  /// if tag in textTag and its text is empty, remove it
  void _removeEmptyTag(Element elem) {
    if (textTag.contains(elem.localName) && elem.text.trim().isEmpty) {
      elem.remove();
      return;
    }
    for (var child in elem.children) {
      _removeEmptyTag(child);
    }
  }
}
