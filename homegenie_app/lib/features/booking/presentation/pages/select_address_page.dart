import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectAddressPage extends ConsumerWidget {
  const SelectAddressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SelectAddress'),
      ),
      body: const Center(
        child: Text('Implementation in progress'),
      ),
    );
  }
}
