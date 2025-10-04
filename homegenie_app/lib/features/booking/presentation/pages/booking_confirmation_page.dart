import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/theme/app_theme.dart';

class BookingConfirmationPage extends ConsumerWidget {
  final String bookingId;

  const BookingConfirmationPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BookingConfirmation'),
      ),
      body: const Center(
        child: Text('Implementation in progress'),
      ),
    );
  }
}
