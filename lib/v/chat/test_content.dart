import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TestContent extends HookConsumerWidget {
  const TestContent(this.testContent, {super.key});

  final String? testContent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Text(testContent ?? ''),
    );
  }
}
