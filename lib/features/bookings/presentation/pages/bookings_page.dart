import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/bookings/domain/entities/appointment_entity.dart';
import 'package:tressy/features/bookings/presentation/bloc/appointments_bloc.dart';
import 'package:tressy/features/bookings/presentation/bloc/appointments_event.dart';
import 'package:tressy/features/bookings/presentation/bloc/appointments_state.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/features/bookings/presentation/widgets/bookings_shimmer.dart';
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
    _tabController = TabController(length: 3, vsync: this);
    _appointmentsBloc = sl<AppointmentsBloc>();
    final isAuthenticated = LocalStorageService.accessToken != null &&
        LocalStorageService.accessToken!.isNotEmpty;
    if (isAuthenticated) {
      _appointmentsBloc.add(const LoadAppointmentsEvent());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  Future<void> _openMapsDirections(
      String lat, String lng, String salonName) async {
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
      onLoginSuccess: () {
        _appointmentsBloc.add(const LoadAppointmentsEvent());
      },
      child: BlocProvider<AppointmentsBloc>.value(
        value: _appointmentsBloc,
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? AppColors.backgroundDark : AppColors.background,
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
              labelColor:
                  isDarkMode ? AppColors.primary : AppColors.primaryDark,
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
                Tab(text: 'Past'),
              ],
            ),
          ),

          // Bookings List
          Expanded(
            child: BlocBuilder<AppointmentsBloc, AppointmentsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return BookingsShimmer.bookingListShimmer(context);
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

                final booked = state.upcoming
                    .where((a) => a.appointmentStatus.toLowerCase() == 'booked')
                    .toList();
                final completed = state.upcoming
                    .where(
                        (a) => a.appointmentStatus.toLowerCase() == 'completed')
                    .toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(booked, 'upcoming', isDarkMode),
                    _buildList(completed, 'completed', isDarkMode),
                    _buildList(state.past, 'past', isDarkMode),
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

  Widget _buildBookingCard(
      AppointmentEntity appointment, String tabStatus, bool isDarkMode) {
    final Color statusColor;
    final Color statusBgColor;
    final String statusText;

    switch (tabStatus) {
      case 'upcoming':
        statusColor = AppColors.white;
        statusBgColor = AppColors.info;
        statusText = 'Upcoming';
        break;
      case 'completed':
        statusColor = AppColors.white;
        statusBgColor = AppColors.success;
        statusText = 'Completed';
        break;
      default: // past
        statusColor = AppColors.white;
        statusBgColor = AppColors.textSecondary;
        statusText = 'Past';
    }

    final imageUrl = appointment.images.isNotEmpty
        ? '${ApiRoutes.imageBaseUrl}/${appointment.images.first}'
        : null;

    final address = [appointment.addressLine1, appointment.city]
        .where((s) => s.isNotEmpty)
        .join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? AppColors.borderDark.withValues(alpha: 0.6)
              : AppColors.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDarkMode ? 0.18 : 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner image with gradient overlay ──
            Stack(
              children: [
                SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _bannerPlaceholder(isDarkMode),
                        )
                      : _bannerPlaceholder(isDarkMode),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                ),
                // Salon name + address on image
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.salonName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (address.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 12, color: Colors.white70),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                address,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Status badge top-right
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Rating badge top-left
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 13, color: Color(0xFFFFD600)),
                        const SizedBox(width: 3),
                        Text(
                          appointment.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Booking info ──
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking ID row
                  Row(
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 14,
                          color: isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary),
                      const SizedBox(width: 5),
                      Text(
                        'Booking #${appointment.id}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Date & Time pills
                  Row(
                    children: [
                      _infoPill(
                        icon: Icons.calendar_today_outlined,
                        label: _formatDate(appointment.bookingDate),
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(width: 8),
                      _infoPill(
                        icon: Icons.access_time_rounded,
                        label:
                            '${_formatTime(appointment.slotFrom)} – ${_formatTime(appointment.slotTo)}',
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Services header
                  Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Service rows
                  ...appointment.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? AppColors.primaryDark
                                    : AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.serviceName,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: isDarkMode
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              '₹${item.amount.toInt()}',
                              style: context.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      )),

                  const SizedBox(height: 10),

                  // Divider + Total
                  Divider(
                      color: isDarkMode
                          ? AppColors.dividerDark
                          : AppColors.divider,
                      height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Paid',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
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
                  const SizedBox(height: 14),
                ],
              ),
            ),

            // ── Directions button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openMapsDirections(
                    appointment.latitude,
                    appointment.longitude,
                    appointment.salonName,
                  ),
                  icon: const Icon(Icons.directions_outlined, size: 18),
                  label: const Text('Get Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDarkMode ? AppColors.primaryDark : AppColors.primary,
                    foregroundColor:
                        isDarkMode ? AppColors.black : AppColors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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

  Widget _infoPill({
    required IconData icon,
    required String label,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.primaryDark.withValues(alpha: 0.08)
            : AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode
              ? AppColors.borderDark.withValues(alpha: 0.5)
              : AppColors.borderColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDarkMode
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bannerPlaceholder(bool isDarkMode) {
    return Container(
      color: isDarkMode
          ? AppColors.primaryDark.withValues(alpha: 0.08)
          : AppColors.primary.withValues(alpha: 0.06),
      child: Center(
        child: Icon(
          Icons.storefront_outlined,
          size: 48,
          color: isDarkMode
              ? AppColors.primaryDark.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}
