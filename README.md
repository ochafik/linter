# Linter for Dart

A Dart style linter.

[![Build Status](https://travis-ci.org/dart-lang/linter.svg)](https://travis-ci.org/dart-lang/linter)
[![Build status](https://ci.appveyor.com/api/projects/status/3a2437l58uhmvckm/branch/master?svg=true)](https://ci.appveyor.com/project/pq/linter/branch/master)
[![Coverage Status](https://coveralls.io/repos/dart-lang/linter/badge.svg)](https://coveralls.io/r/dart-lang/linter)
[![Pub](https://img.shields.io/pub/v/linter.svg)](https://pub.dartlang.org/packages/linter)

## Installing

The linter is bundled with the Dart [SDK](https://www.dartlang.org/tools/sdk); if you have an updated Dart SDK already, you're done!

Alternatively, if you want to contribute to the linter or examine the source, clone the `linter` repo like this:

    $ git clone https://github.com/dart-lang/linter.git

## Usage

The linter gives you feedback to help you catch potential errors and keep your code in line with the published [Dart Style Guide](https://www.dartlang.org/articles/style-guide/). Currently enforcable lint rules (or "lints") are catalogued [here][lints] and can be configured via an [analysis options file][options_file].  The linter is run from within the `dartanalyzer` [command-line tool](https://github.com/dart-lang/sdk/tree/master/pkg/analyzer_cli#dartanalyzer) shipped with the Dart SDK.  Assuming you have lints configured in an `.analysis_options` file with these contents:

```
linter:
  rules:
    - annotate_overrides
    - hash_and_equals
    - prefer_is_not_empty
```
you could lint your package like this:

    $ dartanalyzer --options .analysis_options .
    
and see any violations of the `annotate_overrides`, `hash_and_equals`, and `prefer_is_not_empty` rules in the console.  In practice you would probably configure quite a few more rules (the full list is [here][lints]). For more on configuring analysis, see the analysis option file [docs][options_file].

## Contributing

Feedback is, of course, greatly appreciated and contributions are welcome! Please read the
[contribution guidelines](CONTRIBUTING.md); mechanics of writing lints are covered [here](doc/WritingLints.MD).

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/dart-lang/linter/issues
[lints]: http://dart-lang.github.io/linter/lints/
[options_file]: https://www.dartlang.org/guides/language/analysis-options#the-analysis-options-file

