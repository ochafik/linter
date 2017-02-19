// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.avoid_init_to_null;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

const desc = r"Don't explicitly initialize variables to null";

const details = r'''
From [effective dart]
(https://www.dartlang.org/effective-dart/usage/#dont-explicitly-initialize-variables-to-null):

**DON'T** explicitly initialize variables to null.

In Dart, a variable or field that is not explicitly initialized automatically
gets initialized to null. This is reliably specified by the language. There's
no concept of "uninitialized memory" in Dart. Adding `= null` is redundant and
unneeded.


**GOOD:**
```
int _nextId;

class LazyId {
  int _id;

  int get id {
    if (_nextId == null) _nextId = 0;
    if (_id == null) _id = _nextId++;

    return _id;
  }
}
```

**BAD:**
```
int _nextId = null;

class LazyId {
  int _id = null;

  int get id {
    if (_nextId == null) _nextId = 0;
    if (_id == null) _id = _nextId++;

    return _id;
  }
}
```

''';

class AvoidInitToNull extends LintRule {
  AvoidInitToNull()
      : super(
            name: 'avoid_init_to_null',
            description: desc,
            details: details,
            group: Group.style);

  @override
  AstVisitor getVisitor() => new Visitor(this);
}

class Visitor extends SimpleAstVisitor {
  final LintRule rule;
  Visitor(this.rule);

  @override
  visitVariableDeclaration(VariableDeclaration node) {
    if (node.initializer is NullLiteral && !node.isConst && !node.isFinal) {
      rule.reportLint(node);
    }
  }
}
