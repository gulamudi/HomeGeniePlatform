import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/theme/app_theme.dart';

class AddAddressPage extends ConsumerWidget {
  const AddAddressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AddAddress'),
      ),
      body: const Center(
        child: Text('Implementation in progress'),
      ),
    );
  }
}
