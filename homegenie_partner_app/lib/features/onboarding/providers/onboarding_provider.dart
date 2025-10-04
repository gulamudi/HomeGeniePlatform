import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(false);

  Future<void> completeProfileSetup({
    required String name,
    required String email,
    required List<String> serviceTypes,
  }) async {
    state = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // In production, this would call the API to update partner profile
    // await ref.read(apiClientProvider).updatePartnerProfile(...)

    state = false;
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier();
});
