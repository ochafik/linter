// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.overridden_fields;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:linter/src/analyzer.dart';

const desc = r'Do not override fields.';

const details = r'''

**DO** Do not override fields.

**BAD:**
```
class Base {
  Object field = 'lorem';

  Object something = 'change';
}

class Bad1 extends Base {
  @override
  final field = 'ipsum'; // LINT
}

class Bad2 extends Base {
  @override
  Object something = 'done'; // LINT
}
```

**GOOD:**
```
class Base {
  Object field = 'lorem';

  Object something = 'change';
}

class Ok extends Base {
  Object newField; // OK

  final Object newFinal = 'ignore'; // OK
}
```

**GOOD:**
```
abstract class BaseLoggingHandler {
  Base transformer;
}

class LogPrintHandler implements BaseLoggingHandler {
  @override
  Derived transformer; // OK
}
```
''';

Iterable<InterfaceType> _findAllSupertypesAndMixins(
    InterfaceType interface, List<InterfaceType> accumulator) {
  if (interface == null ||
      interface.isObject ||
      accumulator.contains(interface)) {
    return accumulator;
  }

  accumulator.add(interface);
  InterfaceType superclass = interface.superclass;
  Iterable<InterfaceType> interfaces = [superclass]
    ..addAll(interface.element.mixins)
    ..addAll(_findAllSupertypesAndMixins(superclass, accumulator));
  return interfaces.where((i) => i != interface);
}

class OverriddenFields extends LintRule {
  _Visitor _visitor;

  OverriddenFields()
      : super(
            name: 'overridden_fields',
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
  visitFieldDeclaration(FieldDeclaration node) {
    if (node.isStatic) {
      return;
    }

    node.fields.variables.forEach((VariableDeclaration variable) {
      PropertyAccessorElement field = _getOverriddenMember(variable.element);
      if (field != null) {
        rule.reportLint(variable.name);
      }
    });
  }

  PropertyAccessorElement _getOverriddenMember(Element member) {
    String memberName = member.name;
    LibraryElement library = member.library;
    bool isOverriddenMember(PropertyAccessorElement a) {
      if (a.isSynthetic && a.name == memberName) {
        // Ensure that private members are overriding a member of the same library.
        if (memberName[0] == '_') {
          return library == a.library;
        }
        return true;
      }
      return false;
    }

    bool containsOverriddenMember(InterfaceType i) =>
        i.accessors.any(isOverriddenMember);
    ClassElement classElement = member.enclosingElement;

    Iterable<InterfaceType> interfaces =
        _findAllSupertypesAndMixins(classElement.type, <InterfaceType>[]);
    InterfaceType interface =
        interfaces.firstWhere(containsOverriddenMember, orElse: () => null);
    return interface == null
        ? null
        : interface.accessors.firstWhere(isOverriddenMember);
  }
}
