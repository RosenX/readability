# Readability

readability dart implement, Referencing https://github.com/buriy/python-readability

## Features

Get pure html from raw html content, remove useless tag and attribute

## Usage

```dart
final htmlFile = File('bin/test.html');

final content = await htmlFile.readAsString();

var doc = HtmlDocument(input: content);

doc.parse();

print(doc.pureHtml);
```