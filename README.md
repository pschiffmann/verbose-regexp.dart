RegExp verbose mode in Dart
===========================

[![Build Status](https://travis-ci.com/pschiffmann/verbose-regexp.dart.svg?branch=master)](https://travis-ci.com/pschiffmann/verbose-regexp.dart)

Overview
--------

This package contains a single function `verbose(String) → String` that can be
used to simulate the verbose mode known from other RegEx implementations like
[python][1]. This function will simply remove all unescaped whitespace and
line comments and return a purged Dart regular expression that you can pass to
the RegExp constructor.

Usage
-----

```
import 'package:verbose_regexp/verbose_regexp.dart';

var a = new RegExp(verbose(r'''
  \d +  # the integral part
  \.    # the decimal point
  \d *  # some fractional digits'''));

var b = new RegExp(r'\d+\.\d*');

void main() {
  assert(a == b);
}
```

[1]: https://docs.python.org/3/library/re.html#re.VERBOSE
