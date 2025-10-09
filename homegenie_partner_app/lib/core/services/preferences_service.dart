import '../models/partner_preferences.dart';
import '../models/service_area.dart';
import '../network/api_client.dart';

class PreferencesService {
  final ApiClient _apiClient;

  PreferencesService(this._apiClient);

  /// Get partner preferences
  Future<PartnerPreferences> getPreferences() async {
    try {
      final response = await _apiClient.get('/partner-preferences');

      if (response.statusCode == 200) {
        // Backend wraps response in { success, data } structure
        final responseBody = response.data as Map<String, dynamic>?;

        if (responseBody == null) {
          throw Exception('Received null response');
        }

        // Extract the actual data from the wrapper
        final data = responseBody['data'] as Map<String, dynamic>?;

        if (data == null) {
          throw Exception('Received null data in response');
        }

        print('📥 Received preferences: $data');
        return PartnerPreferences.fromJson(data);
      } else {
        throw Exception('Failed to load preferences: ${response.data}');
      }
    } catch (e) {
      print('❌ Error getting preferences: $e');
      rethrow;
    }
  }

  /// Update partner preferences
  Future<PartnerPreferences> updatePreferences(
      PartnerPreferences preferences) async {
    try {
      print('📤 Updating preferences: ${preferences.toApiJson()}');

      final response = await _apiClient.put(
        '/partner-preferences',
        data: preferences.toApiJson(),
      );

      if (response.statusCode == 200) {
        // Backend wraps response in { success, data } structure
        final responseBody = response.data as Map<String, dynamic>?;

        if (responseBody == null) {
          throw Exception('Received null response');
        }

        // Extract the actual data from the wrapper
        final data = responseBody['data'] as Map<String, dynamic>?;

        if (data == null) {
          throw Exception('Received null data in response');
        }

        print('✅ Preferences updated successfully');
        return PartnerPreferences.fromJson(data);
      } else {
        throw Exception('Failed to update preferences: ${response.data}');
      }
    } catch (e) {
      print('❌ Error updating preferences: $e');
      rethrow;
    }
  }

  /// Get available service areas
  Future<ServiceAreasResponse> getServiceAreas({String? city}) async {
    try {
      final response = await _apiClient.get(
        '/service-areas',
        queryParameters: city != null ? {'city': city} : null,
      );

      if (response.statusCode == 200) {
        // Backend wraps response in { success, data } structure
        final responseBody = response.data as Map<String, dynamic>?;

        if (responseBody == null) {
          throw Exception('Received null response');
        }

        // Extract the actual data from the wrapper
        final data = responseBody['data'] as Map<String, dynamic>?;

        if (data == null) {
          throw Exception('Received null data in response');
        }

        print('📥 Received ${data['count']} service areas');
        return ServiceAreasResponse.fromJson(data);
      } else {
        throw Exception('Failed to load service areas: ${response.data}');
      }
    } catch (e) {
      print('❌ Error getting service areas: $e');
      rethrow;
    }
  }

  /// Check if partner has completed initial setup
  Future<bool> hasCompletedSetup() async {
    try {
      final prefs = await getPreferences();
      // Consider setup complete if partner has at least one service selected
      return prefs.services.isNotEmpty;
    } catch (e) {
      print('Error checking setup status: $e');
      return false;
    }
  }
}
