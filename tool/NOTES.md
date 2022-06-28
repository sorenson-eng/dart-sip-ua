Anthony VanLent's notes for dealing with parser:

The parser generator is `dart v1.24.3` specific. It only runs on `dart v1.24.3`, and will spit out `dart v1.xx.x` complient code. This means the auto generated *grammar_parser.dart* needs some modifications to work in dart v2. It also generated some functions that need changing to massage the unicode to utf8 gap.

## Generate parser (*grammar_parser.dart*):
- Install `Dart 1.24.3`.

  `download from `[dart sdk archive](https://dart.dev/get-dart/archive)

  `extract to reasonable location`

  `add` *${sdk_path}/dart-sdk/bin* `to your system's PATH`

- Clone the peg tool and `pub get`.

  `git clone https://github.com/cloudwebrtc/peg`

  `cd peg`

  `pub get`

- Generate grammar parser

  `dart ${peg_repo}/bin/peg.dart general grammar.peg`

## Update parser for dart v2:
- Change instances of `new List(#)..[0] = $$;` to `List<dynamic>.filled(#, null, growable: true)..[0] = $$;` ( where *#* is an int literal)
  - A regex find of `'new List\((\d+)\)\.\.\[0\] = \$\$;'` and replace with `'List<dynamic>.filled($1, null, growable: false)..[0] = $$$$;'` works well in vs code
- Change `_text` and `_toCodePoints` functions to be:
```dart
String _text([int offset = 0]) {
    return utf8.decode(_input.sublist(_startPos + offset, _cursor));
}
List<int> _toCodePoints(String string) {
return utf8.encode(string);
}
```
- There is a block of variables that need to be nullable and initialized:
```dart
  List<Map<int, List>> _cache = [];

  List<int> _cachePos = [];

  List<bool> _cacheable = [];

  late int _ch;

  late int _cursor;

  List<GrammarParserError> _errors = [];

  List<String?> _expected = [];

  late int _failurePos;

  List<int> _input = [];

  late int _inputLen;

  late int _startPos;

  late int _testing;

  int? _token;

  int? _tokenStart;

  late bool success;

  final String text;
```
- A bunch of functions will have problem warning about return types. Convert their return type to be nullable
- A bunch of places will have problem warnings about using nullable value. Just add `!` to them
- Correct any other warnings. You can gerally refer to the previous version of *grammar_parser.dart* for how to fix