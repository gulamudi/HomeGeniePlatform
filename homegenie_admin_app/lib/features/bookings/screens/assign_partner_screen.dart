import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/bookings_provider.dart';
import '../../../core/network/admin_api_service.dart';

class AssignPartnerScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const AssignPartnerScreen({
    super.key,
    required this.bookingId,
  });

  @override
  ConsumerState<AssignPartnerScreen> createState() =>
      _AssignPartnerScreenState();
}

class _AssignPartnerScreenState extends ConsumerState<AssignPartnerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? searchQuery;
  String selectedFilter = 'All';
  String? verificationStatusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _assignPartner(String partnerId) async {
    try {
      await ref.read(adminApiServiceProvider).assignPartnerToBooking(
            bookingId: widget.bookingId,
            partnerId: partnerId,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Partner assigned successfully')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  PartnerFilters get _currentFilters => PartnerFilters(
        search: searchQuery,
        verificationStatus: verificationStatusFilter,
        onlyVerified: selectedFilter == 'Verified Only',
      );

  @override
  Widget build(BuildContext context) {
    final partnersAsync = ref.watch(availablePartnersProvider(_currentFilters));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Assign Partner',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search partners...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF757575)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value.isEmpty ? null : value);
              },
            ),
          ),
          // Filter Chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: selectedFilter == 'All',
                  onTap: () => setState(() {
                    selectedFilter = 'All';
                    verificationStatusFilter = null;
                  }),
                ),
                const SizedBox(width: 12),
                _FilterChip(
                  label: 'Verified',
                  isSelected: selectedFilter == 'Verified',
                  onTap: () => setState(() {
                    selectedFilter = 'Verified';
                    verificationStatusFilter = 'verified';
                  }),
                ),
                const SizedBox(width: 12),
                _FilterChip(
                  label: 'Pending',
                  isSelected: selectedFilter == 'Pending',
                  onTap: () => setState(() {
                    selectedFilter = 'Pending';
                    verificationStatusFilter = 'pending';
                  }),
                ),
                const SizedBox(width: 12),
                _FilterChip(
                  label: 'Rejected',
                  isSelected: selectedFilter == 'Rejected',
                  onTap: () => setState(() {
                    selectedFilter = 'Rejected';
                    verificationStatusFilter = 'rejected';
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Partner List
          Expanded(
            child: partnersAsync.when(
              data: (partners) {
                if (partners.isEmpty) {
                  return const Center(
                    child: Text('No partners available'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: partners.length,
                  itemBuilder: (context, index) {
                    final partner = partners[index];
                    final profile =
                        partner['partner_profiles'] as Map<String, dynamic>?;
                    final rating = profile?['rating'] ?? 4.5;
                    final verificationStatus = profile?['verification_status'] ?? 'pending';
                    final isAvailable = true; // TODO: Check actual availability

                    return _PartnerCard(
                      name: partner['full_name'] ?? 'Unknown',
                      rating: rating.toDouble(),
                      servicesCompleted: 150,
                      isAvailable: isAvailable,
                      verificationStatus: verificationStatus,
                      onAssign: () => _assignPartner(partner['id']),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFF007B8A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? Colors.white : const Color(0xFF333333),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  final String name;
  final double rating;
  final int servicesCompleted;
  final bool isAvailable;
  final String verificationStatus;
  final VoidCallback onAssign;

  const _PartnerCard({
    required this.name,
    required this.rating,
    required this.servicesCompleted,
    required this.isAvailable,
    required this.verificationStatus,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFE9ECEF),
                  child: Icon(Icons.person, size: 32),
                ),
                if (isAvailable)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$rating ★ • $servicesCompleted+ Services Completed',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getVerificationColor(verificationStatus),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getVerificationLabel(verificationStatus),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAvailable ? 'Available Now' : 'Busy',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isAvailable
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFFC107),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onAssign,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007B8A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Assign',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _getVerificationColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFFFA726);
      case 'rejected':
        return const Color(0xFFEF5350);
      default:
        return Colors.grey;
    }
  }

  static String _getVerificationLabel(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return 'Verified';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }
}
