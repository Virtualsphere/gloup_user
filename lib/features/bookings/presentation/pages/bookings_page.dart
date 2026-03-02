import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/login_required_widget.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Mock bookings data
  final List<Map<String, dynamic>> _allBookings = [
    {
      'id': 'BK001',
      'salonName': 'Elite Hair Studio',
      'salonImage': 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
      'address': 'Koramangala, Bangalore',
      'rating': 4.8,
      'bookingDate': '2024-02-28',
      'bookingTime': '10:00 AM',
      'services': [
        {'name': 'Haircut', 'price': 299.0},
        {'name': 'Beard Trim', 'price': 149.0},
      ],
      'totalAmount': 448.0,
      'paidAmount': 448.0,
      'status': 'completed', // upcoming, completed, cancelled
      'isPremium': true,
      'latitude': 12.9352,
      'longitude': 77.6245,
    },
    {
      'id': 'BK002',
      'salonName': 'Beauty Lounge',
      'salonImage': 'https://images.unsplash.com/photo-1633681926022-84c23e8cb2d6?w=400',
      'address': 'Indiranagar, Bangalore',
      'rating': 4.6,
      'bookingDate': '2024-03-05',
      'bookingTime': '02:00 PM',
      'services': [
        {'name': 'Facial', 'price': 499.0},
        {'name': 'Manicure', 'price': 299.0},
      ],
      'totalAmount': 798.0,
      'paidAmount': 798.0,
      'status': 'upcoming',
      'isPremium': false,
      'latitude': 12.9716,
      'longitude': 77.6412,
    },
    {
      'id': 'BK003',
      'salonName': 'Chic Cuts',
      'salonImage': 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=400',
      'address': 'HSR Layout, Bangalore',
      'rating': 4.7,
      'bookingDate': '2024-02-20',
      'bookingTime': '11:30 AM',
      'services': [
        {'name': 'Hair Styling', 'price': 399.0},
      ],
      'totalAmount': 399.0,
      'paidAmount': 399.0,
      'status': 'completed',
      'isPremium': true,
      'latitude': 12.9082,
      'longitude': 77.6476,
    },
    {
      'id': 'BK004',
      'salonName': 'Glow Spa',
      'salonImage': 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=400',
      'address': 'Rajajinagar, Bangalore',
      'rating': 4.9,
      'bookingDate': '2024-03-10',
      'bookingTime': '04:00 PM',
      'services': [
        {'name': 'Full Body Massage', 'price': 1299.0},
        {'name': 'Facial', 'price': 699.0},
      ],
      'totalAmount': 1998.0,
      'paidAmount': 1998.0,
      'status': 'upcoming',
      'isPremium': true,
      'latitude': 12.9916,
      'longitude': 77.5640,
    },
    {
      'id': 'BK005',
      'salonName': 'Urban Salon',
      'salonImage': 'https://images.unsplash.com/photo-1600948836101-f9ffda59d250?w=400',
      'address': 'BTM Layout, Bangalore',
      'rating': 4.4,
      'bookingDate': '2024-02-15',
      'bookingTime': '09:00 AM',
      'services': [
        {'name': 'Haircut', 'price': 249.0},
      ],
      'totalAmount': 249.0,
      'paidAmount': 249.0,
      'status': 'cancelled',
      'isPremium': false,
      'latitude': 12.9165,
      'longitude': 77.6101,
    },
  ];

  List<Map<String, dynamic>> get _filteredBookings {
    final tabIndex = _tabController.index;
    if (tabIndex == 0) {
      // Upcoming
      return _allBookings.where((b) => b['status'] == 'upcoming').toList();
    } else if (tabIndex == 1) {
      // Completed
      return _allBookings.where((b) => b['status'] == 'completed').toList();
    } else {
      // Cancelled
      return _allBookings.where((b) => b['status'] == 'cancelled').toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return LoginRequiredWidget(
      title: 'Login to View Bookings',
      message: 'Please login to view and manage your salon bookings.',
      showBrowseAsGuest: false, // Don't show "Browse as Guest" in bottom nav screens
      child: _buildContent(context, isDarkMode),
    );
  }

  Widget _buildContent(BuildContext context, bool isDarkMode) {

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: context.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: AppSizes.appBarHeight,
        shape: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppSizes.borderWidthThin,
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.paddingS,
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/ic_search.svg',
                width: AppSizes.iconS,
                height: AppSizes.iconS,
                colorFilter: ColorFilter.mode(
                  isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: AppSizes.spaceS),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search bookings...',
                    hintStyle: context.textTheme.bodyMedium?.copyWith(
                      color: isDarkMode
                          ? AppColors.textHintDark
                          : AppColors.textHint,
                      fontSize: AppSizes.fontS,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                  ),
                  style: context.textTheme.bodyMedium,
                  onChanged: (value) {
                    // Handle search
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingL,
              vertical: AppSizes.paddingM,
            ),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.surfaceDark.withValues(alpha: 0.5)
                  : AppColors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: isDarkMode
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              indicator: BoxDecoration(
                color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: context.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
              ),
              onTap: (index) {
                setState(() {}); // Refresh to show filtered bookings
              },
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Completed'),
                Tab(text: 'Cancelled'),
              ],
            ),
          ),

          // Bookings List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBookingsList('upcoming'),
                _buildBookingsList('completed'),
                _buildBookingsList('cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(String status) {
    final bookings = _filteredBookings;
    final isDarkMode = context.theme.brightness == Brightness.dark;

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: isDarkMode
                  ? AppColors.textSecondaryDark.withValues(alpha: 0.3)
                  : AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSizes.spaceL),
            Text(
              'No $status bookings',
              style: context.textTheme.titleMedium?.copyWith(
                color: isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    final status = booking['status'] as String;

    Color statusColor;
    Color statusBgColor;
    String statusText;

    switch (status) {
      case 'upcoming':
        statusColor = Colors.blue;
        statusBgColor = Colors.blue.withValues(alpha: 0.1);
        statusText = 'Upcoming';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusBgColor = Colors.green.withValues(alpha: 0.1);
        statusText = 'Completed';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusBgColor = Colors.red.withValues(alpha: 0.1);
        statusText = 'Cancelled';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusBgColor = AppColors.textSecondary.withValues(alpha: 0.1);
        statusText = 'Unknown';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingL),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? AppColors.black.withValues(alpha: 0.1)
                : AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Salon Info Header
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Row(
              children: [
                // Salon Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  child: Image.network(
                    booking['salonImage'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.store,
                          color: AppColors.primary,
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSizes.spaceM),
                // Salon Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              booking['salonName'],
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (booking['isPremium'])
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFC02E), Color(0xFFC88C00)],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/ic_crown.svg',
                                    width: 10,
                                    height: 10,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Premium',
                                    style: context.textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: isDarkMode
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              booking['address'],
                              style: context.textTheme.bodySmall?.copyWith(
                                color: isDarkMode
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Color(0xFFFFA500),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            booking['rating'].toString(),
                            style: context.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.border,
          ),

          // Booking Details
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking ID & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Booking ID: ${booking['id']}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingS,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Text(
                        statusText,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spaceM),

                // Date & Time
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      booking['bookingDate'],
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceL),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      booking['bookingTime'],
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spaceM),

                // Services
                Text(
                  'Services:',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceS),
                ...List<Map<String, dynamic>>.from(booking['services']).map((service) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '• ${service['name']}',
                          style: context.textTheme.bodySmall,
                        ),
                        Text(
                          '₹${service['price'].toInt()}',
                          style: context.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: AppSizes.spaceM),

                // Total Amount
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.primaryDark.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Paid Amount',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                        ),
                      ),
                      Text(
                        '₹${booking['paidAmount'].toInt()}',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          if (status == 'upcoming' || status == 'completed')
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Get Directions Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Handle get directions
                        debugPrint('Get directions to ${booking['salonName']}');
                      },
                      icon: const Icon(Icons.directions, size: 18),
                      label: const Text('Directions'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                        side: BorderSide(
                          color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceM),
                  // View Details / Book Again Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (status == 'upcoming') {
                          _showBookingDetailsBottomSheet(context, booking);
                        } else {
                          // Handle book again
                          debugPrint('Book again for ${booking['salonName']}');
                        }
                      },
                      icon: Icon(
                        status == 'upcoming' ? Icons.info_outline : Icons.refresh,
                        size: 18,
                      ),
                      label: Text(status == 'upcoming' ? 'Details' : 'Book Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showBookingDetailsBottomSheet(BuildContext context, Map<String, dynamic> booking) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.backgroundDark : AppColors.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSizes.radiusL),
            topRight: Radius.circular(AppSizes.radiusL),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: AppSizes.paddingM),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                    : AppColors.textSecondary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking Details',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${booking['id']}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: isDarkMode
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: isDarkMode
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: AppColors.border),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Salon Info Card
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        color: context.colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppSizes.radiusS),
                            child: Image.network(
                              booking['salonImage'],
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 70,
                                  height: 70,
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  child: const Icon(Icons.store, size: 35),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: AppSizes.spaceM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking['salonName'],
                                  style: context.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 14, color: Color(0xFFFFA500)),
                                    const SizedBox(width: 4),
                                    Text(
                                      booking['rating'].toString(),
                                      style: context.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: isDarkMode
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        booking['address'],
                                        style: context.textTheme.bodySmall?.copyWith(
                                          color: isDarkMode
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSizes.spaceL),

                    // Appointment Details
                    _buildSectionTitle(context, 'Appointment Details', Icons.calendar_today),
                    const SizedBox(height: AppSizes.spaceM),
                    _buildInfoRow(context, 'Date', booking['bookingDate'], Icons.calendar_today),
                    const SizedBox(height: AppSizes.spaceS),
                    _buildInfoRow(context, 'Time', booking['bookingTime'], Icons.access_time),
                    const SizedBox(height: AppSizes.spaceS),
                    _buildInfoRow(
                      context,
                      'Status',
                      'Upcoming',
                      Icons.info_outline,
                      valueColor: Colors.blue,
                    ),

                    const SizedBox(height: AppSizes.spaceL),

                    // Services
                    _buildSectionTitle(context, 'Services Booked', Icons.cut),
                    const SizedBox(height: AppSizes.spaceM),
                    ...List<Map<String, dynamic>>.from(booking['services']).map((service) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSizes.spaceS),
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppColors.primaryDark.withValues(alpha: 0.05)
                              : AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          border: Border.all(
                            color: isDarkMode
                                ? AppColors.primaryDark.withValues(alpha: 0.2)
                                : AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              service['name'],
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '₹${service['price'].toInt()}',
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: AppSizes.spaceL),

                    // Payment Summary
                    _buildSectionTitle(context, 'Payment Summary', Icons.payment),
                    const SizedBox(height: AppSizes.spaceM),
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingL),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.surfaceDark
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        border: Border.all(
                          color: AppColors.border,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Total Amount Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: isDarkMode
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '₹${booking['totalAmount'].toInt()}',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: AppSizes.spaceM),
                          
                          // Divider
                          Container(
                            height: 1,
                            color: AppColors.border,
                          ),
                          
                          const SizedBox(height: AppSizes.spaceM),
                          
                          // Paid Amount Row (Highlighted)
                          Container(
                            padding: const EdgeInsets.all(AppSizes.paddingM),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? AppColors.primaryDark.withValues(alpha: 0.1)
                                  : AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppSizes.radiusS),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: AppSizes.spaceS),
                                    Text(
                                      'Paid Amount',
                                      style: context.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '₹${booking['paidAmount'].toInt()}',
                                  style: context.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSizes.spaceL),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
              child: Column(
                children: [
                  // Contact & View Salon buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Handle contact salon
                            debugPrint('Contact ${booking['salonName']}');
                          },
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Contact'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                            side: BorderSide(
                              color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.spaceM),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to salon details
                            debugPrint('View salon details');
                          },
                          icon: const Icon(Icons.store, size: 18),
                          label: const Text('View Salon'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceM),
                  // Cancel Booking button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Show cancel confirmation dialog
                        _showCancelConfirmation(context, booking);
                      },
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancel Booking'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
        ),
        const SizedBox(width: AppSizes.spaceS),
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDarkMode
              ? AppColors.textSecondaryDark
              : AppColors.textSecondary,
        ),
        const SizedBox(width: AppSizes.spaceS),
        Text(
          '$label: ',
          style: context.textTheme.bodyMedium?.copyWith(
            color: isDarkMode
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  void _showCancelConfirmation(BuildContext context, Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
          'Are you sure you want to cancel this booking at ${booking['salonName']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close bottom sheet
              // Handle cancellation
              debugPrint('Booking ${booking['id']} cancelled');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
