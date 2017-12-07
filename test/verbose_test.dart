import 'package:test/test.dart';
import 'package:verbose_regexp/verbose_regexp.dart';

void main() {
  group('verbose', () {
    test('removes whitespace and comments', () {
      final v = '''
        abc #comment
          #comment 2
            de  f
      ''';
      expect(verbose(v), equals('abcdef'));
    });

    test('keeps escaped whitespace and `#` characters', () {
      final v = r'''
        ab\ c \#comment
        \
      ''';
      expect(verbose(v), equals('ab c#comment\n'));
    });

    test('ignores whitespace and `#` characters in character groups', () {
      final v = r'''
        a[ ]b[#] no[# ] comment
      ''';
      expect(verbose(v), equals(r'a[ ]b[#]no[# ]comment'));
    });

    test('leaves escape sequences and character groups intact', () {
      final v = r'''
        \\\\\s
        [ -z\[\]\\]
      ''';
      expect(verbose(v), equals(r'\\\\\s[ -z\[\]\\]'));
    });
  });
}
