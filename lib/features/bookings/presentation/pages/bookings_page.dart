import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/features/bookings/domain/entities/appointment_entity.dart';
import 'package:tressy/features/bookings/presentation/bloc/appointments_bloc.dart';
import 'package:tressy/features/bookings/presentation/bloc/appointments_event.dart';
import 'package:tressy/features/bookings/presentation/bloc/appointments_state.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/login_required_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AppointmentsBloc _appointmentsBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _appointmentsBloc = sl<AppointmentsBloc>();
    _appointmentsBloc.add(const LoadAppointmentsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _appointmentsBloc.close();
    super.dispose();
  }

  String _formatDate(String date) {
    // "2026-03-07T00:00:00.000Z" or "2026-03-07" → "07-03-2026"
    try {
      final datePart = date.split('T').first;
      final parts = datePart.split('-');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    } catch (_) {}
    return date;
  }

  String _formatTime(String time) {
    // "15:30:00" → "3:30 PM"
    try {
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      final int minute = int.parse(parts[1]);
      final String period = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return '$hour:${minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return time;
    }
  }

  Future<void> _openMapsDirections(String lat, String lng, String salonName) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$salonName&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoginRequiredWidget(
      title: 'Login to View Bookings',
      message: 'Please login to view and manage your salon bookings.',
      showBrowseAsGuest: false,
      child: BlocProvider<AppointmentsBloc>.value(
        value: _appointmentsBloc,
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

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
        title: Text(
          'My Bookings',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
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
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Completed'),
              ],
            ),
          ),

          // Bookings List
          Expanded(
            child: BlocBuilder<AppointmentsBloc, AppointmentsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSizes.spaceM),
                        Text(
                          state.errorMessage!,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: isDarkMode
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.spaceL),
                        ElevatedButton(
                          onPressed: () => _appointmentsBloc
                              .add(const LoadAppointmentsEvent()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(state.upcoming, 'upcoming', isDarkMode),
                    _buildList(state.past, 'completed', isDarkMode),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
      List<AppointmentEntity> appointments, String tabStatus, bool isDarkMode) {
    final label = tabStatus;
    if (appointments.isEmpty) {
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
              'No $label bookings',
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
      padding: const EdgeInsets.all(AppSizes.paddingL),
      itemCount: appointments.length,
      itemBuilder: (context, index) =>
          _buildBookingCard(appointments[index], tabStatus, isDarkMode),
    );
  }

  Widget _buildBookingCard(AppointmentEntity appointment, String tabStatus, bool isDarkMode) {
    final status = tabStatus;

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
      default:
        statusColor = AppColors.textSecondary;
        statusBgColor = AppColors.textSecondary.withValues(alpha: 0.1);
        statusText = status;
    }

    final imageUrl = appointment.images.isNotEmpty
        ? '${ApiRoutes.imageBaseUrl}/${appointment.images.first}'
        : null;

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
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderImage(),
                        )
                      : _placeholderImage(),
                ),
                const SizedBox(width: AppSizes.spaceM),
                // Salon Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.salonName,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                              [
                                appointment.addressLine1,
                                appointment.city,
                              ]
                                  .where((s) => s.isNotEmpty)
                                  .join(', '),
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
                            appointment.averageRating.toStringAsFixed(1),
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

          Divider(height: 1, thickness: 1, color: AppColors.border),

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
                      'Booking ID: #${appointment.id}',
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
                      color: isDarkMode
                          ? AppColors.primaryDark
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(appointment.bookingDate),
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceL),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: isDarkMode
                          ? AppColors.primaryDark
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatTime(appointment.slotFrom)} - ${_formatTime(appointment.slotTo)}',
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
                ...appointment.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '• ${item.serviceName}',
                            style: context.textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          '₹${item.amount.toInt()}',
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
                          color: isDarkMode
                              ? AppColors.primaryDark
                              : AppColors.primary,
                        ),
                      ),
                      Text(
                        '₹${appointment.discountedAmount.toInt()}',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? AppColors.primaryDark
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Directions Button
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openMapsDirections(
                  appointment.latitude,
                  appointment.longitude,
                  appointment.salonName,
                ),
                icon: const Icon(Icons.directions, size: 18),
                label: const Text('Get Directions'),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      isDarkMode ? AppColors.primaryDark : AppColors.primary,
                  side: BorderSide(
                    color:
                        isDarkMode ? AppColors.primaryDark : AppColors.primary,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 60,
      height: 60,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Icon(Icons.store, color: AppColors.primary, size: 30),
    );
  }
}
