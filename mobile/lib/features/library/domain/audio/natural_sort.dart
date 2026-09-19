int naturalCompare(String a, String b) {
  if (a == b) return 0;

  final tokensA = _tokenize(a);
  final tokensB = _tokenize(b);
  final shared =
      tokensA.length < tokensB.length ? tokensA.length : tokensB.length;

  for (var i = 0; i < shared; i++) {
    final x = tokensA[i];
    final y = tokensB[i];
    final int comparison;
    if (x.isNumber && y.isNumber) {
      comparison = _compareNumbers(x.text, y.text);
    } else if (!x.isNumber && !y.isNumber) {
      comparison = x.text.toLowerCase().compareTo(y.text.toLowerCase());
    } else {
      comparison = x.isNumber ? -1 : 1;
    }
    if (comparison != 0) return comparison;
  }

  if (tokensA.length != tokensB.length) {
    return tokensA.length - tokensB.length;
  }
  return a.compareTo(b);
}

int _compareNumbers(String a, String b) {
  final strippedA = _stripLeadingZeros(a);
  final strippedB = _stripLeadingZeros(b);
  if (strippedA.length != strippedB.length) {
    return strippedA.length - strippedB.length;
  }
  return strippedA.compareTo(strippedB);
}

String _stripLeadingZeros(String value) {
  var index = 0;
  while (index < value.length - 1 && value.codeUnitAt(index) == 0x30) {
    index++;
  }
  return value.substring(index);
}

bool _isAsciiDigit(int codeUnit) => codeUnit >= 0x30 && codeUnit <= 0x39;

List<_Token> _tokenize(String input) {
  final tokens = <_Token>[];
  final buffer = StringBuffer();
  bool? bufferIsNumber;

  for (final codeUnit in input.codeUnits) {
    final digit = _isAsciiDigit(codeUnit);
    if (bufferIsNumber == null || digit == bufferIsNumber) {
      buffer.writeCharCode(codeUnit);
      bufferIsNumber = digit;
    } else {
      tokens.add(_Token(buffer.toString(), bufferIsNumber));
      buffer
        ..clear()
        ..writeCharCode(codeUnit);
      bufferIsNumber = digit;
    }
  }
  if (buffer.isNotEmpty) {
    tokens.add(_Token(buffer.toString(), bufferIsNumber ?? false));
  }
  return tokens;
}

class _Token {
  const _Token(this.text, this.isNumber);

  final String text;
  final bool isNumber;
}
