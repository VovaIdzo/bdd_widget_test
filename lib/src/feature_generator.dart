import 'package:bdd_widget_test/src/bdd_line.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:bdd_widget_test/src/step_generator.dart';

String generateFeatureDart(List<BddLine> lines, List<StepFile> steps) {
  final sb = StringBuffer();
  sb.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  sb.writeln('// ignore_for_file: unused_import');
  sb.writeln('');
  sb.writeln('import \'package:flutter/material.dart\';');
  sb.writeln('import \'package:flutter_test/flutter_test.dart\';');
  sb.writeln('');

  for (final step in steps.map((e) => e.import).toSet()) {
    sb.writeln('import \'$step\';');
  }

  sb.writeln('');
  sb.writeln('void main() {');

  final features = splitWhen(lines, (e) => e.type == LineType.feature);

  for (final feature in features) {
    sb.writeln('  group(\'${feature.first.value}\', () {');

    final scenarios =
        splitWhen(feature.skip(1), (e) => e.type == LineType.scenario).toList();
    for (final scenario in scenarios) {
      sb.writeln(
          '    testWidgets(\'${scenario.first.value}\', (WidgetTester tester) async {');

      for (final step in scenario.skip(1)) {
        sb.writeln('      await ${_generateStepCall(step.value)};');
      }

      sb.writeln('    });');
    }
    sb.writeln('  });');
  }
  sb.writeln('}');
  return sb.toString();
}

String _generateStepCall(String stepLine) {
  final name = getStepMethodName(stepLine);

  final regExp = RegExp(r'(?<=\{)\S+(?=\})', caseSensitive: false);
  final params = regExp.allMatches(stepLine);
  if (params.isEmpty) {
    return '$name(tester)';
  }

  final methodParameters = params.map((p) => p.group(0)).join(', ');
  return '$name(tester, $methodParameters)';
}

List<List<T>> splitWhen<T>(Iterable<T> original, bool Function(T) predicate) =>
    original.fold(<List<T>>[], (previousValue, element) {
      if (predicate(element)) {
        previousValue.add([element]);
      } else {
        previousValue.last.add(element);
      }
      return previousValue;
    });