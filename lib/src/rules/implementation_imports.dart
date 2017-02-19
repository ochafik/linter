// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.implementation_imports;

import 'package:analyzer/dart/ast/ast.dart' show AstVisitor, ImportDirective;
import 'package:analyzer/dart/ast/standard_resolution_map.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

const desc = "Don't import implementation files from another package.";

const details = '''
**DON'T** import implementation files from another package.

From the the [pub package layout doc]
(https://www.dartlang.org/tools/pub/package-layout.html#implementation-files):

The libraries inside `lib` are publicly visible: other packages are free to
import them. But much of a package's code is internal implementation libraries
that should only be imported and used by the package itself. Those go inside a
subdirectory of `lib` called `src`. You can create subdirectories in there if
it helps you organize things.

You are free to import libraries that live in `lib/src` from within other Dart
code in the same package (like other libraries in `lib`, scripts in `bin`,
and tests) but you should never import from another package's `lib/src`
directory. Those files are not part of the package’s public API, and they
might change in ways that could break your code.

**Bad:**

```
// In 'road_runner'
import 'package:acme/lib/src/internals.dart;
```
''';

bool isImplementation(Uri uri) {
  List<String> segments = uri?.pathSegments ?? const [];
  if (segments.length > 2) {
    if (segments[1] == 'src') {
      return true;
    }
  }
  return false;
}

bool isPackage(Uri uri) => uri?.scheme == 'package';

bool samePackage(Uri uri1, Uri uri2) {
  var segments1 = uri1.pathSegments;
  var segments2 = uri2.pathSegments;
  if (segments1.length < 1 || segments2.length < 1) {
    return false;
  }
  return segments1[0] == segments2[0];
}

class ImplementationImports extends LintRule {
  ImplementationImports()
      : super(
            name: 'implementation_imports',
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
  visitImportDirective(ImportDirective node) {
    Uri importUri = node?.uriSource?.uri;
    Uri sourceUri = node == null
        ? null
        : resolutionMap.elementDeclaredByDirective(node)?.source?.uri;

    // Test for 'package:*/src/'.
    if (!isImplementation(importUri)) {
      return;
    }

    // If the source URI is not a `package` URI bail out.
    if (!isPackage(sourceUri)) {
      return;
    }

    if (!samePackage(importUri, sourceUri)) {
      rule.reportLint(node.uri);
    }
  }
}
