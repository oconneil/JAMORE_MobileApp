import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('domain depends on Dart and domain modules only', () {
    _expectNoImports('lib/domain', const [
      'package:flutter',
      '/application/',
      '/data/',
      '/infrastructure/',
      '/presentation/',
      '/state/',
      '/core/',
    ]);
  });

  test('application depends inward on domain only', () {
    _expectNoImports('lib/application', const [
      'package:flutter',
      '/data/',
      '/infrastructure/',
      '/presentation/',
      '/state/',
    ]);
  });

  test('presentation does not reach data or infrastructure adapters', () {
    for (final path in ['lib/presentation', 'lib/state']) {
      _expectNoImports(path, const ['/data/', '/infrastructure/']);
    }
  });
}

void _expectNoImports(String root, List<String> forbidden) {
  final violations = <String>[];
  for (final entity in Directory(root).listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final source = entity.readAsStringSync();
    for (final dependency in forbidden) {
      if (source.contains(dependency)) {
        violations.add('${entity.path} imports $dependency');
      }
    }
  }
  expect(violations, isEmpty, reason: violations.join('\n'));
}
