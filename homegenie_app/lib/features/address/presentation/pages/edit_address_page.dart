import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/theme/app_theme.dart';

class EditAddressPage extends ConsumerWidget {
  final String addressId;

  const EditAddressPage({super.key, required this.addressId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EditAddress'),
      ),
      body: const Center(
        child: Text('Implementation in progress'),
      ),
    );
  }
}
