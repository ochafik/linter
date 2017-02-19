// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.library_names;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

const desc =
    'Name libraries and source files using `lowercase_with_underscores`.';

const details = r'''
**DO** name libraries and source files using `lowercase_with_underscores`.

Some file systems are not case-sensitive, so many projects require filenames
to be all lowercase. Using a separate character allows names to still be
readable in that form. Using underscores as the separator ensures that the name
is still a valid Dart identifier, which may be helpful if the language later
supports symbolic imports.

**GOOD:**

* `slider_menu.dart`
* `file_system.dart`
* `library peg_parser;`

**BAD:**

* `SliderMenu.dart`
* `filesystem.dart`
* `library peg-parser;`
''';

class LibraryNames extends LintRule {
  LibraryNames()
      : super(
            name: 'library_names',
            description: desc,
            details: details,
            group: Group.style);

  @override
  AstVisitor getVisitor() => new Visitor(this);
}

class Visitor extends SimpleAstVisitor {
  LintRule rule;
  Visitor(this.rule);

  @override
  visitLibraryDirective(LibraryDirective node) {
    if (!Analyzer.facade.isLowerCaseUnderScoreWithDots(node.name.toString())) {
      rule.reportLint(node.name);
    }
  }
}
