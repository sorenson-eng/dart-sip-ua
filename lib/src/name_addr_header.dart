import 'grammar.dart';
import 'uri.dart';
import 'utils.dart';

// derived from https://www.rfc-editor.org/rfc/rfc3261.html#section-25
final RegExp illegalDisplayNameCharacters = RegExp(r'\x0A|\x0D'); // LF, CR
final String illegalReplacement = '';
// need to escape ASCII (0x00-0x7F) except for LF 0x0A, CR 0x0D, SPACE 0x20, ! 0x21, and 'regular' chars (0x23-5B,5D-7E)
final RegExp needEscapingDisplayNameChars =
    RegExp(r'[\x00-\x09]|\x0B|\x0C|[\x0E-\x1F]|\x22|\x5C|\x7F');

class NameAddrHeader {
  NameAddrHeader(URI? uri, String? display_name,
      [Map<dynamic, dynamic>? parameters]) {
    // Checks.
    if (uri == null) {
      throw AssertionError('missing or invalid "uri" = $uri parameter');
    }

    // Initialize parameters.
    _uri = uri;
    _parameters = <dynamic, dynamic>{};
    _display_name = display_name;

    if (parameters != null) {
      parameters.forEach((dynamic key, dynamic param) {
        setParam(key, param);
      });
    }
  }
  URI? _uri;
  Map<dynamic, dynamic>? _parameters;
  String? _display_name;
  /**
   * Parse the given string and returns a NameAddrHeader instance or null if
   * it is an invalid NameAddrHeader.
   */
  static dynamic parse(String name_addr_header) {
    dynamic parsed = Grammar.parse(name_addr_header, 'Name_Addr_Header');
    if (parsed != -1) {
      return parsed;
    } else {
      return null;
    }
  }

  URI? get uri => _uri;

  String? get display_name => _display_name;

  set display_name(dynamic value) {
    _display_name = (value == 0) ? '0' : value;
  }

  void setParam(String? key, dynamic value) {
    if (key != null) {
      _parameters![key.toLowerCase()] =
          (value == null) ? null : value.toString();
    }
  }

  dynamic getParam(String key) {
    if (key != null) {
      return _parameters![key.toLowerCase()];
    }
  }

  bool hasParam(String key) {
    if (key != null) {
      return _parameters!.containsKey(key.toLowerCase());
    }
    return false;
  }

  dynamic deleteParam(String parameter) {
    parameter = parameter.toLowerCase();
    if (_parameters![parameter] != null) {
      dynamic value = _parameters![parameter];
      _parameters!.remove(parameter);
      return value;
    }
  }

  void clearParams() {
    _parameters = <dynamic, dynamic>{};
  }

  NameAddrHeader clone() {
    return NameAddrHeader(_uri!.clone(), _display_name,
        decoder.convert(encoder.convert(_parameters)));
  }

  // remove illegal chars and escape where needed
  String _cleanseDisplayName(String dirty) {
    dirty = dirty.replaceAll(illegalDisplayNameCharacters, illegalReplacement);
    String clean = dirty.replaceAllMapped(needEscapingDisplayNameChars, (Match match) {
      String? found = match.group(0);
      if (found != null) {
        return '\\$found';
      } else {
        return '';
      }
    });
    return clean;
  }

  @override
  String toString() {
    String body = (_display_name != null && _display_name!.length > 0)
        ? '"${_cleanseDisplayName(_display_name!)}" '
        : '';

    body += '<${_uri.toString()}>';

    _parameters!.forEach((dynamic key, dynamic value) {
      if (_parameters!.containsKey(key)) {
        body += ';$key';
        if (value != null) {
          body += '=$value';
        }
      }
    });

    return body;
  }
}
