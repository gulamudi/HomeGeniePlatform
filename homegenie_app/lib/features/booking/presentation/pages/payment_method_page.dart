import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/theme/app_theme.dart';

class PaymentMethodPage extends ConsumerWidget {
  const PaymentMethodPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PaymentMethod'),
      ),
      body: const Center(
        child: Text('Implementation in progress'),
      ),
    );
  }
}
