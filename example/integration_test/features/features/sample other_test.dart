// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../sharedSteps/the_app_is_running.dart';
import '../../sharedSteps/i_do_not_see_text.dart';
import '../../sharedSteps/i_tap_icon.dart';
import './step/i_tap_icon_more.dart';
import '../../sharedSteps/i_see_text.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> bddSetUp(WidgetTester tester) async {
    await theAppIsRunning(tester);
  }
  Future<void> bddTearDown(WidgetTester tester) async {
    await iDoNotSeeText(tester, 'surprise');
  }
  group('''Counter decreise''', () {
    testWidgets('''Add button twice increments the counter''', (tester) async {
      try {
        await bddSetUp(tester);
        print("When I tap {Icons.add} icon");
        await iTapIcon(tester, Icons.add);
        print("And I tap {Icons.add} icon more");
        await iTapIconMore(tester, Icons.add);
        print("Then I see {'2'} text");
        await iSeeText(tester, '2');
      } finally {
        await bddTearDown(tester);
      }
    });
  });
}
