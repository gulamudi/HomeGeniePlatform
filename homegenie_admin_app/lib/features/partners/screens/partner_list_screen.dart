import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/partners_provider.dart';

class PartnerListScreen extends ConsumerStatefulWidget {
  const PartnerListScreen({super.key});

  @override
  ConsumerState<PartnerListScreen> createState() => _PartnerListScreenState();
}

class _PartnerListScreenState extends ConsumerState<PartnerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? searchQuery;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getAvailabilityColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return const Color(0xFF2A9D8F);
      case 'busy':
        return const Color(0xFFE9C46A);
      case 'offline':
        return const Color(0xFFE63946);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final partnersAsync = ref.watch(partnersProvider(searchQuery));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.menu, size: 28),
                  const Text(
                    'Partners',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D3557),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name, service, or location',
                  hintStyle: const TextStyle(color: Color(0xFF3A86FF)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF3A86FF)),
                  filled: true,
                  fillColor: const Color(0xFF3A86FF).withOpacity(0.2),
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
            const SizedBox(height: 12),
            // Filter Chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _FilterChip(label: 'Service Type'),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Verification'),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Availability'),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Color(0xFFD0D0D0),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No more partners found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filters.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(partnersProvider(searchQuery));
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: partners.length,
                      itemBuilder: (context, index) {
                      final partner = partners[index];
                      final profile = partner['partner_profiles']
                          as Map<String, dynamic>?;
                      final rating = profile?['rating'] ?? 4.0;
                      // Mock availability - in real app, fetch from profile
                      final availability = index % 3 == 0
                          ? 'available'
                          : index % 3 == 1
                              ? 'busy'
                              : 'offline';

                      return _PartnerCard(
                        name: partner['full_name'] ?? 'Unknown',
                        contactInfo: partner['email'] ?? partner['phone'] ?? 'No contact',
                        rating: rating.toDouble(),
                        availability: availability,
                        availabilityColor: _getAvailabilityColor(availability),
                        onTap: () => context.push('/partners/${partner['id']}'),
                      );
                    },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/partners/create'),
        backgroundColor: const Color(0xFF3A86FF),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;

  const _FilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3A86FF).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1D3557),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.expand_more,
            size: 20,
            color: Color(0xFF1D3557),
          ),
        ],
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  final String name;
  final String contactInfo;
  final double rating;
  final String availability;
  final Color availabilityColor;
  final VoidCallback onTap;

  const _PartnerCard({
    required this.name,
    required this.contactInfo,
    required this.rating,
    required this.availability,
    required this.availabilityColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFFE9ECEF),
                    child: Icon(Icons.person, size: 28),
                  ),
                  const SizedBox(width: 12),
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
                        Row(
                          children: [
                            Icon(
                              contactInfo.contains('@')
                                  ? Icons.email
                                  : Icons.phone,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              contactInfo,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (index) => Icon(
                                index < rating.floor()
                                    ? Icons.star
                                    : index < rating
                                        ? Icons.star_half
                                        : Icons.star_outline,
                                size: 16,
                                color: const Color(0xFFE9C46A),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: Color(0xFF3A86FF),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: availabilityColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        availability[0].toUpperCase() + availability.substring(1),
                        style: TextStyle(
                          color: availabilityColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: onTap,
                    child: const Text(
                      'View/Edit Profile',
                      style: TextStyle(
                        color: Color(0xFF3A86FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
