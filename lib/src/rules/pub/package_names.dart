// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.pub.package_names;

import 'package:linter/src/analyzer.dart';
import 'package:linter/src/ast.dart';

const desc = 'Use `lowercase_with_underscores` for package names.';

const details = '''
**DO** use `lowercase_with_underscores` for package names.

From the [Pubspec format description]
(https://www.dartlang.org/tools/pub/pubspec.html):

Package names should be all lowercase, with underscores to separate words,
`just_like_this`. Use only basic Latin letters and Arabic digits: [a-z0-9_].
Also, make sure the name is a valid Dart identifier -- that it doesn't start
with digits and isn't a reserved word.
''';

bool isValidPackageName(String id) =>
    Analyzer.facade.isLowerCaseUnderScore(id) && isValidDartIdentifier(id);

class PubPackageNames extends LintRule {
  PubPackageNames()
      : super(
            name: 'package_names',
            description: desc,
            details: details,
            group: Group.pub);

  @override
  PubspecVisitor getPubspecVisitor() => new Visitor(this);
}

class Visitor extends PubspecVisitor {
  LintRule rule;
  Visitor(this.rule);

  @override
  visitPackageName(PSEntry name) {
    if (!isValidPackageName(name.value.text)) {
      rule.reportPubLint(name.value);
    }
  }
}
