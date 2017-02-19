// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.await_only_futures;

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/util/dart_type_utilities.dart';

const desc = 'Await only futures.';

const details = '''
**AVOID** await on anything other than a future.

**BAD:**
```
main() async {
  print(await 23);
}
```

**GOOD:**
```
main() async {
  print(await new Future.value(23));
}
```
''';

class AwaitOnlyFutures extends LintRule {
  _Visitor _visitor;

  AwaitOnlyFutures()
      : super(
            name: 'await_only_futures',
            description: desc,
            details: details,
            group: Group.style) {
    _visitor = new _Visitor(this);
  }

  @override
  AstVisitor getVisitor() => _visitor;
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  visitAwaitExpression(AwaitExpression node) {
    final DartType type = node.expression.bestType;
    if (!(type.isDartAsyncFuture ||
        type.isDynamic ||
        DartTypeUtilities.extendsClass(type, 'Future', 'dart.async') ||
        DartTypeUtilities.implementsInterface(type, 'Future', 'dart.async'))) {
      rule.reportLint(node);
    }
  }
}
