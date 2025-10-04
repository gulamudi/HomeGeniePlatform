import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectDateTimePage extends ConsumerWidget {
  const SelectDateTimePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SelectDateTime'),
      ),
      body: const Center(
        child: Text('Implementation in progress'),
      ),
    );
  }
}
