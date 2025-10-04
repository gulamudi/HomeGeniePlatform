import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/address_provider.dart';
import 'add_address_page.dart';

class EditAddressPage extends ConsumerWidget {
  final String addressId;

  const EditAddressPage({super.key, required this.addressId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final address = ref.watch(addressByIdProvider(addressId));

    if (address == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Address'),
        ),
        body: const Center(
          child: Text('Address not found'),
        ),
      );
    }

    return AddAddressPage(address: address);
  }
}
