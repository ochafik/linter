// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.avoid_empty_else;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

const desc = r'Avoid empty else statements.';

const details = r'''
Avoid empty else statements.

**BAD:**
```
if (x > y)
  print("1");
else ;
  print("2");
```
''';

class AvoidEmptyElse extends LintRule {
  AvoidEmptyElse()
      : super(
            name: 'avoid_empty_else',
            description: desc,
            details: details,
            group: Group.errors);

  @override
  AstVisitor getVisitor() => new Visitor(this);
}

class Visitor extends SimpleAstVisitor {
  final LintRule rule;
  Visitor(this.rule);

  @override
  visitIfStatement(IfStatement node) {
    Statement elseStatement = node.elseStatement;
    if (elseStatement is EmptyStatement) {
      rule.reportLint(elseStatement);
    }
  }
}
