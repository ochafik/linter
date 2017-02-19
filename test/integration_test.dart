// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.test.integration;

import 'dart:io';

import 'package:analyzer/src/lint/config.dart';
import 'package:analyzer/src/lint/io.dart';
import 'package:analyzer/src/lint/linter.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../bin/linter.dart' as dartlint;
import 'mocks.dart';

main() {
  defineTests();
}

defineTests() {
  group('integration', () {
    group('p2', () {
      IOSink currentOut = outSink;
      CollectingSink collectingOut = new CollectingSink();
      setUp(() {
        exitCode = 0;
        outSink = collectingOut;
      });
      tearDown(() {
        collectingOut.buffer.clear();
        outSink = currentOut;
        exitCode = 0;
      });
      group('config', () {
        test('excludes', () {
          dartlint
              .main(['test/_data/p2', '-c', 'test/_data/p2/lintconfig.yaml']);
          expect(exitCode, 1);
          expect(
              collectingOut.trim(),
              stringContainsInOrder(
                  ['4 files analyzed, 1 issue found (2 filtered), in']));
        });
        test('overrrides', () {
          dartlint
              .main(['test/_data/p2', '-c', 'test/_data/p2/lintconfig2.yaml']);
          expect(exitCode, 0);
          expect(collectingOut.trim(),
              stringContainsInOrder(['4 files analyzed, 0 issues found, in']));
        });
        test('default', () {
          dartlint.main(['test/_data/p2']);
          expect(exitCode, 1);
          expect(collectingOut.trim(),
              stringContainsInOrder(['4 files analyzed, 3 issues found, in']));
        });
      });
    });
    group('p3', () {
      IOSink currentOut = outSink;
      CollectingSink collectingOut = new CollectingSink();
      setUp(() => outSink = collectingOut);
      tearDown(() {
        collectingOut.buffer.clear();
        outSink = currentOut;
      });
      test('bad pubspec', () {
        dartlint.main(['test/_data/p3', 'test/_data/p3/_pubpspec.yaml']);
        expect(collectingOut.trim(),
            startsWith('1 file analyzed, 0 issues found, in'));
      });
    });
    group('p4', () {
      IOSink currentOut = outSink;
      CollectingSink collectingOut = new CollectingSink();
      setUp(() => outSink = collectingOut);
      tearDown(() {
        collectingOut.buffer.clear();
        outSink = currentOut;
      });
      test('no warnings due to bad canonicalization', () {
        var packagesFilePath =
            new File('test/_data/p4/_packages').absolute.path;
        dartlint.runLinter(['--packages', packagesFilePath, 'test/_data/p4'],
            new LinterOptions([]));
        expect(collectingOut.trim(),
            startsWith('3 files analyzed, 0 issues found, in'));
      });
    });

    group('p5', () {
      IOSink currentOut = outSink;
      CollectingSink collectingOut = new CollectingSink();
      setUp(() {
        exitCode = 0;
        outSink = collectingOut;
      });
      tearDown(() {
        collectingOut.buffer.clear();
        outSink = currentOut;
        exitCode = 0;
      });
      group('.packages', () {
        test('basic', () {
          // Requires .packages to analyze cleanly.
          dartlint
              .main(['test/_data/p5', '--packages', 'test/_data/p5/_packages']);
          // Should have 0 issues.
          expect(exitCode, 0);
        });
      });
    });

    group('p8', () {
      IOSink currentOut = outSink;
      CollectingSink collectingOut = new CollectingSink();
      setUp(() {
        exitCode = 0;
        outSink = collectingOut;
      });
      tearDown(() {
        collectingOut.buffer.clear();
        outSink = currentOut;
        exitCode = 0;
      });
      group('config', () {
        test('filtered', () {
          dartlint
              .main(['test/_data/p8', '-c', 'test/_data/p8/lintconfig.yaml']);
          expect(exitCode, 0);
          expect(
              collectingOut.trim(),
              stringContainsInOrder(
                  ['2 files analyzed, 0 issues found (1 filtered), in']));
        });
      });
    });

    group('overridden_fields', () {
      IOSink currentOut = outSink;
      CollectingSink collectingOut = new CollectingSink();
      setUp(() {
        exitCode = 0;
        outSink = collectingOut;
      });
      tearDown(() {
        collectingOut.buffer.clear();
        outSink = currentOut;
        exitCode = 0;
      });

      // https://github.com/dart-lang/linter/issues/246
      test('overrides across libraries', () {
        dartlint.main(
            ['test/_data/overridden_fields', '--rules', 'overridden_fields']);
        expect(exitCode, 1);
        expect(
            collectingOut.trim(),
            stringContainsInOrder(
                ['int public;', '2 files analyzed, 1 issue found, in']));
      });
    });

    group('close_sinks', () {
      IOSink currentOut = outSink;
      CollectingSink collectingOut = new CollectingSink();
      setUp(() {
        exitCode = 0;
        outSink = collectingOut;
      });
      tearDown(() {
        collectingOut.buffer.clear();
        outSink = currentOut;
        exitCode = 0;
      });

      test('close sinks', () {
        var packagesFilePath = new File('.packages').absolute.path;
        dartlint.main([
          '--packages',
          packagesFilePath,
          'test/_data/close_sinks',
          '--rules=close_sinks'
        ]);
        expect(exitCode, 1);
        expect(
            collectingOut.trim(),
            stringContainsInOrder([
              'IOSink _sinkA; // LINT',
              'IOSink _sinkSomeFunction; // LINT',
              '1 file analyzed, 2 issues found, in'
            ]));
      });
    });

    group('cancel_subscriptions', () {
      IOSink currentOut = outSink;
      CollectingSink collectingOut = new CollectingSink();
      setUp(() {
        exitCode = 0;
        outSink = collectingOut;
      });
      tearDown(() {
        collectingOut.buffer.clear();
        outSink = currentOut;
        exitCode = 0;
      });

      test('cancel subscriptions', () {
        dartlint.main([
          'test/_data/cancel_subscriptions',
          '--rules=cancel_subscriptions'
        ]);
        expect(exitCode, 1);
        expect(
            collectingOut.trim(),
            stringContainsInOrder([
              'StreamSubscription _subscriptionA; // LINT',
              'StreamSubscription _subscriptionF; // LINT',
              '1 file analyzed, 3 issues found, in'
            ]));
      });
    });

    group('directives_ordering', () {
      IOSink currentOut = outSink;
      CollectingSink collectingOut = new CollectingSink();
      setUp(() {
        exitCode = 0;
        outSink = collectingOut;
      });
      tearDown(() {
        collectingOut.buffer.clear();
        outSink = currentOut;
        exitCode = 0;
      });

      test('dart_imports_go_first', () {
        var packagesFilePath = new File('.packages').absolute.path;
        dartlint.main([
          '--packages',
          packagesFilePath,
          'test/_data/directives_ordering/dart_imports_go_first',
          '--rules=directives_ordering'
        ]);
        expect(exitCode, 1);
        expect(
            collectingOut.trim(),
            stringContainsInOrder([
              "Place 'dart:' imports before other imports.",
              "import 'dart:async';  // LINT",
              "Place 'dart:' imports before other imports.",
              "import 'dart:html';  // LINT",
              '2 files analyzed, 2 issues found, in'
            ]));
      });
    });

    group('only_throw_errors', () {
      IOSink currentOut = outSink;
      CollectingSink collectingOut = new CollectingSink();
      setUp(() {
        exitCode = 0;
        outSink = collectingOut;
      });
      tearDown(() {
        collectingOut.buffer.clear();
        outSink = currentOut;
        exitCode = 0;
      });

      test('only throw errors', () {
        dartlint.main(
            ['test/_data/only_throw_errors', '--rules=only_throw_errors']);
        expect(exitCode, 1);
        expect(
            collectingOut.trim(),
            stringContainsInOrder([
              "throw 'hello world!'; // LINT",
              'throw null; // LINT',
              'throw 7; // LINT',
              'throw new Object(); // LINT',
              'throw returnString(); // LINT',
              '1 file analyzed, 5 issues found, in'
            ]));
      });
    });

    group('examples', () {
      test('lintconfig.yaml', () {
        var src = readFile('example/lintconfig.yaml');
        var config = new LintConfig.parse(src);
        expect(config.fileIncludes, unorderedEquals(['foo/**']));
        expect(
            config.fileExcludes, unorderedEquals(['**/_data.dart', 'test/**']));
        expect(config.ruleConfigs, hasLength(1));
        var ruleConfig = config.ruleConfigs[0];
        expect(ruleConfig.group, 'style_guide');
        expect(ruleConfig.name, 'unnecessary_getters');
        expect(ruleConfig.args, {'enabled': false});
      });
    });
  });
}

class MockProcessResult extends Mock implements ProcessResult {}
