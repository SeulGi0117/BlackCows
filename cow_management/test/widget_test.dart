// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cow_management/main.dart';

void main() {
  testWidgets('앱 위젯 smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SoDamApp());
    // 추가 테스트 코드 작성 가능
  });
}
