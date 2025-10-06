import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';

final jobActionsProvider = Provider((ref) {
  return JobActionsNotifier();
});

class JobActionsNotifier {
  final _supabase = SupabaseService.instance;

  Future<void> acceptJob(String jobId, {String? estimatedArrival}) async {
    try {
      print('🟢 [JobActionsNotifier] Accepting job $jobId');

      final partnerId = _supabase.currentUserId;
      if (partnerId == null) {
        throw Exception('Partner not authenticated');
      }

      await _supabase.acceptJob(
        bookingId: jobId,
        partnerId: partnerId,
      );

      print('✅ [JobActionsNotifier] Job accepted successfully');
    } catch (e, stackTrace) {
      print('❌ [JobActionsNotifier] Error accepting job: $e');
      print('   Stack trace: $stackTrace');
      throw Exception('Failed to accept job: $e');
    }
  }

  Future<void> rejectJob(String jobId, String reason) async {
    try {
      print('🔴 [JobActionsNotifier] Rejecting job $jobId with reason: $reason');

      await _supabase.rejectJob(
        bookingId: jobId,
        reason: reason,
      );

      print('✅ [JobActionsNotifier] Job rejected successfully');
    } catch (e, stackTrace) {
      print('❌ [JobActionsNotifier] Error rejecting job: $e');
      print('   Stack trace: $stackTrace');
      throw Exception('Failed to reject job: $e');
    }
  }
}
