import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/address.dart';
import '../../providers/address_provider.dart';

class AddAddressPage extends ConsumerStatefulWidget {
  final Address? address; // For edit mode

  const AddAddressPage({super.key, this.address});

  @override
  ConsumerState<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends ConsumerState<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _flatHouseNoController = TextEditingController();
  final _buildingNameController = TextEditingController();
  final _streetNameController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _areaController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinCodeController = TextEditingController();

  String _selectedType = 'home';
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _flatHouseNoController.text = widget.address!.flat_house_no;
      _buildingNameController.text = widget.address!.building_apartment_name ?? '';
      _streetNameController.text = widget.address!.street_name;
      _landmarkController.text = widget.address!.landmark ?? '';
      _areaController.text = widget.address!.area;
      _cityController.text = widget.address!.city;
      _stateController.text = widget.address!.state;
      _pinCodeController.text = widget.address!.pin_code;
      _selectedType = widget.address!.type;
      _isDefault = widget.address!.is_default;
    }
  }

  @override
  void dispose() {
    _flatHouseNoController.dispose();
    _buildingNameController.dispose();
    _streetNameController.dispose();
    _landmarkController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final address = Address(
        id: widget.address?.id,
        flat_house_no: _flatHouseNoController.text.trim(),
        building_apartment_name: _buildingNameController.text.trim().isNotEmpty
          ? _buildingNameController.text.trim()
          : null,
        street_name: _streetNameController.text.trim(),
        landmark: _landmarkController.text.trim().isNotEmpty
          ? _landmarkController.text.trim()
          : null,
        area: _areaController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pin_code: _pinCodeController.text.trim(),
        type: _selectedType,
        is_default: _isDefault,
      );

      if (widget.address == null) {
        await ref.read(addressesProvider.notifier).addAddress(address);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address added successfully')),
          );
        }
      } else {
        await ref.read(addressesProvider.notifier).updateAddress(
          widget.address!.id!,
          address,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address updated successfully')),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: isDark
          ? const Color(0xFF101922)
          : const Color(0xFFF6F7F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.address == null ? 'Add Address' : 'Edit Address',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _flatHouseNoController,
                      label: 'Flat/House No.',
                      hint: 'e.g., 101',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter flat/house number';
                        }
                        return null;
                      },
                      isDark: isDark,
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _buildingNameController,
                      label: 'Building/Apartment Name (Optional)',
                      hint: 'e.g., Green Valley',
                      isDark: isDark,
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _streetNameController,
                      label: 'Street Name',
                      hint: 'e.g., MG Road',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter street name';
                        }
                        return null;
                      },
                      isDark: isDark,
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _landmarkController,
                      label: 'Landmark (Optional)',
                      hint: 'e.g., Near City Mall',
                      isDark: isDark,
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _areaController,
                      label: 'Area',
                      hint: 'e.g., Sector 15',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter area';
                        }
                        return null;
                      },
                      isDark: isDark,
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _cityController,
                            label: 'City',
                            hint: 'e.g., Mumbai',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter city';
                              }
                              return null;
                            },
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _stateController,
                            label: 'State',
                            hint: 'e.g., Maharashtra',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter state';
                              }
                              return null;
                            },
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _pinCodeController,
                      label: 'Pin Code',
                      hint: 'e.g., 400001',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter pin code';
                        }
                        if (value.trim().length != 6) {
                          return 'Pin code must be 6 digits';
                        }
                        return null;
                      },
                      isDark: isDark,
                    ),

                    const SizedBox(height: 24),

                    // Address Type Selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Address Type',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTypeChip('home', 'Home', Icons.home, isDark),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTypeChip('work', 'Work', Icons.work, isDark),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTypeChip('other', 'Other', Icons.location_on, isDark),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Set as Default Checkbox
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isDefault,
                            onChanged: (value) {
                              setState(() {
                                _isDefault = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFF1173D4),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Set as default address',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : Colors.grey[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  ),
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1173D4),
                      disabledBackgroundColor: Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.address == null ? 'Save Address' : 'Update Address',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.grey[900],
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            filled: true,
            fillColor: isDark ? Colors.grey[900] : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF1173D4),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeChip(String value, String label, IconData icon, bool isDark) {
    final isSelected = _selectedType == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
            ? const Color(0xFF1173D4)
            : (isDark ? Colors.grey[800] : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
              ? const Color(0xFF1173D4)
              : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                ? Colors.white
                : (isDark ? Colors.grey[400] : Colors.grey[600]),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
