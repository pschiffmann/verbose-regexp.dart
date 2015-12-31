/// Simulates [verbose flag][1] behavior for regular expressions in Dart.
///
/// [1]: https://docs.python.org/3/library/re.html#re.VERBOSE
library verbose_regexp.verbose_regexp;

/// Removes unescaped whitespace and line comments from `regexp`.
///
/// Whitespace counts as unescaped if it is not preceded by a backslash or
/// enclosed in a character group.
/// Unescaped `#` characters starts a line comment, that is ended at `\n`.
String verbose(String regexp) => regexp.splitMapJoin(
  _escapeSequence,
  onMatch: (Match m) => m.group(1) ?? m.group(2),
  onNonMatch: (String str) => str.replaceAll(_verboseMatcher, '')
);

/// Matches backslashes and character groups.
final RegExp _escapeSequence = new RegExp(
  r'(?:\\(#|\s))'   // Group 1 matches an escaped whitespace or `#` character.
                    // Remove the escape character, keep the escaped one.
  r'|'
  r'('              // Group 2 filters out stuff that interferes with the other
                    // replacements. These strings are written back into the
                    // result unaltered:
    r'\\[\s\S]'     // - Any escaped character, including backslashes. This way
                    //   we count the number of backslashes before a whitespace
                    //   or `#` character.
    r'|'
    r'\[('          // - All character groups, because they might include
      r'\\[\s\S]'   //   whitespace or `#` characters.
      r'|'
      r'[^\]]'
    r')*\]'
  r')'
);

/// Matches strings that are treated as verbose and therefore should be ignored.
final RegExp _verboseMatcher = new RegExp('#[^\n]*\n?|\\s');
