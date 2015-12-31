import 'package:test/test.dart';
import 'package:verbose_regexp/verbose_regexp.dart';

void main() {
  group('verbose', () {

    test('removes whitespace and comments', () {
      var v = '''
        abc #comment
          #comment 2
            de  f
      ''';
      expect(verbose(v), equals('abcdef'));
    });

    test('keeps escaped whitespace and `#` characters', () {
      var v = r'''
        ab\ c \#comment
        \
      ''';
      expect(verbose(v), equals('ab c#comment\n'));
    });

    test('ignores whitespace and `#` characters in character groups', () {
      var v = r'''
        a[ ]b[#] no[# ] comment
      ''';
      expect(verbose(v), equals(r'a[ ]b[#]no[# ]comment'));
    });

    test('leaves escape sequences and character groups intact', () {
      var v = r'''
        \\\\\s
        [ -z\[\]\\]
      ''';
      expect(verbose(v), equals(r'\\\\\s[ -z\[\]\\]'));
    });
  });
}
