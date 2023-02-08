// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../sharedSteps/the_app_is_running.dart';
import '../../sharedSteps/i_do_not_see_text.dart';
import '../../sharedSteps/i_see_text.dart';
import '../../sharedSteps/i_tap_icon.dart';
import './step/i_tap_icon_times.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> bddSetUp(WidgetTester tester) async {
    await theAppIsRunning(tester);
  }
  Future<void> bddTearDown(WidgetTester tester) async {
    await iDoNotSeeText(tester, 'surprise');
  }
  group('''Counter''', () {
    testWidgets('''Initial counter value is 0''', (tester) async {
      try {
        await bddSetUp(tester);
        print("Then I see {'0'} text");
        await iSeeText(tester, '0');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''Add button increments the counter''', (tester) async {
      try {
        await bddSetUp(tester);
        print("When I tap {Icons.add} icon");
        await iTapIcon(tester, Icons.add);
        print("Then I see {'1'} text");
        await iSeeText(tester, '1');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''Outline: Plus button increases the counter (0, '0')''', (tester) async {
      try {
        await bddSetUp(tester);
        print("");
        await theAppIsRunning(tester);
        print("");
        await iTapIconTimes(tester, Icons.add, 0);
        print("");
        await iSeeText(tester, '0');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''Outline: Plus button increases the counter (1, '1')''', (tester) async {
      try {
        await bddSetUp(tester);
        print("");
        await theAppIsRunning(tester);
        print("");
        await iTapIconTimes(tester, Icons.add, 1);
        print("");
        await iSeeText(tester, '1');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''Outline: Plus button increases the counter (42, '42')''', (tester) async {
      try {
        await bddSetUp(tester);
        print("");
        await theAppIsRunning(tester);
        print("");
        await iTapIconTimes(tester, Icons.add, 42);
        print("");
        await iSeeText(tester, '42');
      } finally {
        await bddTearDown(tester);
      }
    });
  });
}
