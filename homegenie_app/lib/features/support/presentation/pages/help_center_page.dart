import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HelpCenterPage extends ConsumerWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HelpCenter'),
      ),
      body: const Center(
        child: Text('Implementation in progress'),
      ),
    );
  }
}
