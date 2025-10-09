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
        // Backend now guarantees non-null objects for availability and jobPreferences
        final data = response.data as Map<String, dynamic>?;

        if (data == null) {
          throw Exception('Received null response data');
        }

        return PartnerPreferences.fromJson(data);
      } else {
        throw Exception('Failed to load preferences: ${response.data}');
      }
    } catch (e) {
      print('Error getting preferences: $e');
      rethrow;
    }
  }

  /// Update partner preferences
  Future<PartnerPreferences> updatePreferences(
      PartnerPreferences preferences) async {
    try {
      final response = await _apiClient.put(
        '/partner-preferences',
        data: preferences.toApiJson(),
      );

      if (response.statusCode == 200) {
        return PartnerPreferences.fromJson(response.data);
      } else {
        throw Exception('Failed to update preferences: ${response.data}');
      }
    } catch (e) {
      print('Error updating preferences: $e');
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
        return ServiceAreasResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load service areas: ${response.data}');
      }
    } catch (e) {
      print('Error getting service areas: $e');
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
