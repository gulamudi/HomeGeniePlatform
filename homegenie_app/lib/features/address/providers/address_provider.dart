import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/address.dart';
import '../../../core/network/api_service.dart';
import '../../../core/providers/api_provider.dart';

class AddressesNotifier extends StateNotifier<List<Address>> {
  final ApiService _apiService;

  AddressesNotifier(this._apiService) : super([]);

  Future<void> loadAddresses() async {
    try {
      final response = await _apiService.getAddresses();
      if (response.success && response.data != null) {
        final addressList = (response.data as List)
            .map((json) => Address.fromJson(json as Map<String, dynamic>))
            .toList();
        state = addressList;
      }
    } catch (e) {
      // If API fails, use mock data for development
      state = [
        const Address(
          id: '1',
          flat_house_no: '101',
          building_apartment_name: 'Green Valley Apartments',
          street_name: 'MG Road',
          landmark: 'Near City Mall',
          area: 'Whitefield',
          city: 'Bangalore',
          state: 'Karnataka',
          pin_code: '560066',
          type: 'home',
          is_default: true,
        ),
        const Address(
          id: '2',
          flat_house_no: 'Floor 5',
          building_apartment_name: 'Tech Park',
          street_name: 'ITPL Main Road',
          landmark: 'Opposite Metro Station',
          area: 'Whitefield',
          city: 'Bangalore',
          state: 'Karnataka',
          pin_code: '560066',
          type: 'work',
          is_default: false,
        ),
      ];
    }
  }

  Future<void> addAddress(Address address) async {
    try {
      final response = await _apiService.addAddress({
        'flat_house_no': address.flat_house_no,
        'building_apartment_name': address.building_apartment_name,
        'street_name': address.street_name,
        'landmark': address.landmark,
        'area': address.area,
        'city': address.city,
        'state': address.state,
        'pin_code': address.pin_code,
        'type': address.type,
        'is_default': address.is_default,
      });

      if (response.success && response.data != null) {
        final newAddress = Address.fromJson(response.data as Map<String, dynamic>);

        // If new address is default, unset all others
        if (newAddress.is_default) {
          state = state.map((a) => Address(
            id: a.id,
            flat_house_no: a.flat_house_no,
            building_apartment_name: a.building_apartment_name,
            street_name: a.street_name,
            landmark: a.landmark,
            area: a.area,
            city: a.city,
            state: a.state,
            pin_code: a.pin_code,
            type: a.type,
            is_default: false,
          )).toList();
        }

        state = [...state, newAddress];
      }
    } catch (e) {
      // Fallback to mock implementation
      final shouldBeDefault = state.isEmpty || address.is_default;

      if (shouldBeDefault) {
        state = state.map((a) => Address(
          id: a.id,
          flat_house_no: a.flat_house_no,
          building_apartment_name: a.building_apartment_name,
          street_name: a.street_name,
          landmark: a.landmark,
          area: a.area,
          city: a.city,
          state: a.state,
          pin_code: a.pin_code,
          type: a.type,
          is_default: false,
        )).toList();
      }

      final newAddress = Address(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        flat_house_no: address.flat_house_no,
        building_apartment_name: address.building_apartment_name,
        street_name: address.street_name,
        landmark: address.landmark,
        area: address.area,
        city: address.city,
        state: address.state,
        pin_code: address.pin_code,
        type: address.type,
        is_default: shouldBeDefault,
      );

      state = [...state, newAddress];
    }
  }

  Future<void> updateAddress(String id, Address address) async {
    try {
      final response = await _apiService.updateAddress({
        'id': id,
        'flat_house_no': address.flat_house_no,
        'building_apartment_name': address.building_apartment_name,
        'street_name': address.street_name,
        'landmark': address.landmark,
        'area': address.area,
        'city': address.city,
        'state': address.state,
        'pin_code': address.pin_code,
        'type': address.type,
        'is_default': address.is_default,
      });

      if (response.success) {
        // If updating to default, unset all others
        if (address.is_default) {
          state = state.map((a) => a.id == id ? address : Address(
            id: a.id,
            flat_house_no: a.flat_house_no,
            building_apartment_name: a.building_apartment_name,
            street_name: a.street_name,
            landmark: a.landmark,
            area: a.area,
            city: a.city,
            state: a.state,
            pin_code: a.pin_code,
            type: a.type,
            is_default: false,
          )).toList();
        } else {
          state = state.map((a) => a.id == id ? address : a).toList();
        }
      }
    } catch (e) {
      // Fallback to mock implementation
      if (address.is_default) {
        state = state.map((a) => a.id == id ? address : Address(
          id: a.id,
          flat_house_no: a.flat_house_no,
          building_apartment_name: a.building_apartment_name,
          street_name: a.street_name,
          landmark: a.landmark,
          area: a.area,
          city: a.city,
          state: a.state,
          pin_code: a.pin_code,
          type: a.type,
          is_default: false,
        )).toList();
      } else {
        state = state.map((a) => a.id == id ? address : a).toList();
      }
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      final response = await _apiService.deleteAddress({'id': id});

      if (response.success) {
        state = state.where((a) => a.id != id).toList();

        // If we deleted the default address and have others, set first as default
        if (state.isNotEmpty && !state.any((a) => a.is_default)) {
          state = [
            Address(
              id: state[0].id,
              flat_house_no: state[0].flat_house_no,
              building_apartment_name: state[0].building_apartment_name,
              street_name: state[0].street_name,
              landmark: state[0].landmark,
              area: state[0].area,
              city: state[0].city,
              state: state[0].state,
              pin_code: state[0].pin_code,
              type: state[0].type,
              is_default: true,
            ),
            ...state.skip(1),
          ];
        }
      }
    } catch (e) {
      // Fallback to mock implementation
      state = state.where((a) => a.id != id).toList();

      if (state.isNotEmpty && !state.any((a) => a.is_default)) {
        state = [
          Address(
            id: state[0].id,
            flat_house_no: state[0].flat_house_no,
            building_apartment_name: state[0].building_apartment_name,
            street_name: state[0].street_name,
            landmark: state[0].landmark,
            area: state[0].area,
            city: state[0].city,
            state: state[0].state,
            pin_code: state[0].pin_code,
            type: state[0].type,
            is_default: true,
          ),
          ...state.skip(1),
        ];
      }
    }
  }

  Future<void> setDefaultAddress(String id) async {
    try {
      // Update via API
      final addressToUpdate = state.firstWhere((a) => a.id == id);
      await updateAddress(id, Address(
        id: addressToUpdate.id,
        flat_house_no: addressToUpdate.flat_house_no,
        building_apartment_name: addressToUpdate.building_apartment_name,
        street_name: addressToUpdate.street_name,
        landmark: addressToUpdate.landmark,
        area: addressToUpdate.area,
        city: addressToUpdate.city,
        state: addressToUpdate.state,
        pin_code: addressToUpdate.pin_code,
        type: addressToUpdate.type,
        is_default: true,
      ));
    } catch (e) {
      // Fallback to mock implementation
      state = state.map((a) => Address(
        id: a.id,
        flat_house_no: a.flat_house_no,
        building_apartment_name: a.building_apartment_name,
        street_name: a.street_name,
        landmark: a.landmark,
        area: a.area,
        city: a.city,
        state: a.state,
        pin_code: a.pin_code,
        type: a.type,
        is_default: a.id == id,
      )).toList();
    }
  }
}

// Providers
final addressesProvider = StateNotifierProvider<AddressesNotifier, List<Address>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final notifier = AddressesNotifier(apiService);
  notifier.loadAddresses();
  return notifier;
});

final defaultAddressProvider = Provider<Address?>((ref) {
  final addresses = ref.watch(addressesProvider);
  try {
    return addresses.firstWhere((a) => a.is_default);
  } catch (e) {
    return addresses.isNotEmpty ? addresses.first : null;
  }
});

final addressByIdProvider = Provider.family<Address?, String>((ref, id) {
  final addresses = ref.watch(addressesProvider);
  try {
    return addresses.firstWhere((a) => a.id == id);
  } catch (e) {
    return null;
  }
});
