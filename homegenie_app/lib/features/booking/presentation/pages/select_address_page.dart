import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../address/providers/address_provider.dart';
import '../../../address/presentation/pages/add_address_page.dart';
import '../../providers/booking_provider.dart';

class SelectAddressPage extends ConsumerStatefulWidget {
  const SelectAddressPage({super.key});

  @override
  ConsumerState<SelectAddressPage> createState() => _SelectAddressPageState();
}

class _SelectAddressPageState extends ConsumerState<SelectAddressPage> {
  String? _selectedAddressId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final addresses = ref.watch(addressesProvider);
    final defaultAddress = ref.watch(defaultAddressProvider);

    // Initialize with default address if available
    if (_selectedAddressId == null && defaultAddress != null) {
      _selectedAddressId = defaultAddress.id;
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: isDark
          ? const Color(0xFF101922).withOpacity(0.8)
          : const Color(0xFFF6F7F8).withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Select Address',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: addresses.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off_outlined,
                  size: 64,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No addresses saved',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add an address to continue',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddAddressPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Address'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1173D4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          )
        : Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose an address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Address List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: addresses.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final address = addresses[index];
                          final isSelected = _selectedAddressId == address.id;

                          IconData typeIcon;
                          switch (address.type.toLowerCase()) {
                            case 'home':
                              typeIcon = Icons.home;
                              break;
                            case 'work':
                            case 'office':
                              typeIcon = Icons.work;
                              break;
                            default:
                              typeIcon = Icons.location_on;
                          }

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedAddressId = address.id;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[800] : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                    ? const Color(0xFF1173D4)
                                    : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1173D4).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      typeIcon,
                                      color: const Color(0xFF1173D4),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Address Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              address.type.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.white : Colors.grey[900],
                                              ),
                                            ),
                                            if (address.is_default) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF1173D4).withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'DEFAULT',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF1173D4),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${address.flat_house_no}, ${address.building_apartment_name ?? ''} ${address.street_name}, ${address.area}, ${address.city}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Radio Button
                                  Radio<String>(
                                    value: address.id!,
                                    groupValue: _selectedAddressId,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedAddressId = value;
                                      });
                                    },
                                    activeColor: const Color(0xFF1173D4),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Add New Address Button
                      OutlinedButton.icon(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AddAddressPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add New Address'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1173D4),
                          side: const BorderSide(color: Color(0xFF1173D4)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Bar with Continue Button
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
                      onPressed: _selectedAddressId != null
                        ? () {
                            final selectedAddress = addresses.firstWhere(
                              (a) => a.id == _selectedAddressId,
                            );

                            // Save address to booking state
                            ref.read(bookingProvider.notifier).setAddress(selectedAddress);

                            // Navigate to checkout
                            context.push('/booking/checkout');
                          }
                        : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1173D4),
                        disabledBackgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
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
    );
  }
}
