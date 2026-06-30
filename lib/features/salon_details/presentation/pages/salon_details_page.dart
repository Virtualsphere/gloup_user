import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/constants/salon_detail_design_tokens.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/features/salon_details/domain/entities/salon_detail_entity.dart';
import 'package:tressy/features/salon_details/presentation/bloc/salon_detail_bloc.dart';
import 'package:tressy/features/salon_details/presentation/bloc/salon_detail_event.dart';
import 'package:tressy/features/salon_details/presentation/bloc/salon_detail_state.dart';
import 'package:tressy/features/salon_details/presentation/cubit/salon_details_page_cubit.dart';
import 'package:tressy/features/salon_details/presentation/cubit/salon_details_page_state.dart';
import 'package:tressy/features/salon_details/presentation/widgets/salon_details_action_bar.dart';
import 'package:tressy/features/salon_details/presentation/widgets/salon_details_bottom_bar.dart';
import 'package:tressy/features/salon_details/presentation/widgets/salon_details_sections.dart';
import 'package:tressy/features/salon_details/presentation/widgets/salon_details_shimmers.dart';
import 'package:tressy/features/salon_details/presentation/utils/salon_share.dart';
import 'package:tressy/features/salon_details/presentation/widgets/salon_all_reviews_sheet.dart';
import 'package:tressy/features/salon_details/presentation/widgets/salon_gallery_section.dart';
import 'package:tressy/features/salon_details/presentation/widgets/salon_header_section.dart';
import 'package:tressy/features/salon_details/presentation/widgets/salon_reviews_section.dart';
import 'package:tressy/features/salon_details/presentation/widgets/salon_services_section.dart';
import 'package:tressy/features/salon_details/presentation/widgets/salon_team_section.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/error_widget.dart' as custom;

class SalonDetailsPage extends StatefulWidget {
  final String? salonId;

  const SalonDetailsPage({
    super.key,
    this.salonId,
  });

  @override
  State<SalonDetailsPage> createState() => _SalonDetailsPageState();
}

class SalonDetailsPageWrapper extends StatelessWidget {
  final String? salonId;

  const SalonDetailsPageWrapper({
    super.key,
    this.salonId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<SalonDetailBloc>()..add(LoadSalonDetailEvent(salonId ?? '')),
        ),
        BlocProvider(create: (context) => SalonDetailsPageCubit()),
      ],
      child: SalonDetailsPage(salonId: salonId),
    );
  }
}

class _SalonDetailsPageState extends State<SalonDetailsPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _bottomNavController;
  late Animation<Offset> _bottomNavAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _bottomNavController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bottomNavAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bottomNavController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _bottomNavController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final screenHeight = context.screenHeight;
    final carouselHeight =
        screenHeight * SalonDetailDesignTokens.carouselHeightFraction;
    final isCollapsed = _scrollController.hasClients &&
        _scrollController.offset > (carouselHeight * 0.5);
    context.read<SalonDetailsPageCubit>().setCollapsed(isCollapsed);
  }

  void _toggleService(ServiceEntity service) {
    final cubit = context.read<SalonDetailsPageCubit>();
    final wasEmpty = cubit.serviceCount == 0;
    cubit.toggleService(service);

    if (wasEmpty && cubit.serviceCount > 0) {
      _bottomNavController.forward();
    } else if (!wasEmpty && cubit.serviceCount == 0) {
      _bottomNavController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenHeight;
    final carouselHeight =
        screenHeight * SalonDetailDesignTokens.carouselHeightFraction;
    final collapsedHeight = screenHeight * 0.08;
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return BlocConsumer<SalonDetailBloc, SalonDetailState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, detailState) {
        return BlocBuilder<SalonDetailsPageCubit, SalonDetailsPageState>(
          builder: (context, pageState) {
            final pageCubit = context.read<SalonDetailsPageCubit>();
            return Scaffold(
              backgroundColor: isDarkMode
                  ? AppColors.surfaceDark
                  : SalonDetailDesignTokens.pageBackground,
              bottomNavigationBar: SalonDetailsBottomBar(
                isDarkMode: isDarkMode,
                bottomNavAnimation: _bottomNavAnimation,
                selectedServices: pageState.selectedServices,
                totalPrice: pageCubit.totalPrice,
                serviceCount: pageCubit.serviceCount,
                highestOfferPercentage: pageCubit.highestOfferPercentage,
                salonId: widget.salonId,
              ),
              body: Stack(
                children: [
                  CustomScrollView(
                    controller: _scrollController,
                    clipBehavior: Clip.none,
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        expandedHeight: carouselHeight,
                        collapsedHeight: collapsedHeight,
                        backgroundColor: isDarkMode
                            ? AppColors.surfaceDark
                            : SalonDetailDesignTokens.pageBackground,
                        surfaceTintColor: Colors.transparent,
                        clipBehavior: Clip.none,
                        elevation: 0,
                        shape: pageState.isCollapsed
                            ? Border(
                                bottom: BorderSide(
                                  color: AppColors.border,
                                  width: AppSizes.borderWidthThin,
                                ),
                              )
                            : null,
                        automaticallyImplyLeading: false,
                        flexibleSpace: LayoutBuilder(
                          builder: (context, constraints) {
                            final isFullyExpanded =
                                constraints.maxHeight > collapsedHeight + 50;
                            return FlexibleSpaceBar(
                              background: detailState.isLoading
                                  ? SalonDetailsShimmers.buildCarouselShimmer(
                                      context, isDarkMode)
                                  : detailState.salonDetail != null
                                      ? SalonGallerySection(
                                          carouselHeight: carouselHeight,
                                          isDarkMode: isDarkMode,
                                          isFullyExpanded: isFullyExpanded,
                                          salonDetail: detailState.salonDetail!,
                                          currentImageIndex:
                                              pageState.currentImageIndex,
                                          onImageChanged: (index) {
                                            context
                                                .read<SalonDetailsPageCubit>()
                                                .setImageIndex(index);
                                          },
                                        )
                                      : const SizedBox.shrink(),
                              collapseMode: CollapseMode.pin,
                              centerTitle: false,
                              titlePadding: EdgeInsets.zero,
                            );
                          },
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: SalonStickyHeaderDelegate(
                          extent: SalonDetailDesignTokens.stickyHeaderExtent,
                          child: SalonHeaderSection(
                            isDarkMode: isDarkMode,
                            state: detailState,
                            activeTabIndex: pageState.activeTabIndex,
                            tabs: pageCubit.tabs,
                            onTabChanged: (index) {
                              context
                                  .read<SalonDetailsPageCubit>()
                                  .setActiveTab(index);
                            },
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _buildContent(
                          context: context,
                          isDarkMode: isDarkMode,
                          detailState: detailState,
                          pageState: pageState,
                          pageCubit: pageCubit,
                        ),
                      ),
                    ],
                  ),
                  SalonDetailsActionBar(
                    isCollapsed: pageState.isCollapsed,
                    isDarkMode: isDarkMode,
                    onShare: detailState.salonDetail != null
                        ? () => SalonShare.shareSalon(detailState.salonDetail!)
                        : null,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required bool isDarkMode,
    required SalonDetailState detailState,
    required SalonDetailsPageState pageState,
    required SalonDetailsPageCubit pageCubit,
  }) {
    if (detailState.isLoading) {
      return Column(
        children: [
          ...SalonDetailsSections.buildSectionShimmers(
            context: context,
            tabs: pageCubit.tabs,
            isDarkMode: isDarkMode,
            sectionKeys: pageCubit.sectionKeys,
          ),
          const SizedBox(height: 100),
        ],
      );
    }

    if (detailState.errorMessage != null && detailState.salonDetail == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingXL),
          child: custom.ErrorDisplayWidget(
            message: detailState.errorMessage!,
            onRetry: () {
              context
                  .read<SalonDetailBloc>()
                  .add(LoadSalonDetailEvent(widget.salonId ?? ''));
            },
          ),
        ),
      );
    }

    if (detailState.salonDetail == null) {
      return const SizedBox.shrink();
    }

    final salonDetail = detailState.salonDetail!;
    final activeTitle = pageCubit.tabs[pageState.activeTabIndex];

    return Column(
      children: [
        SalonDetailsSections(
          title: activeTitle,
          isDarkMode: isDarkMode,
          salonDetail: salonDetail,
          sectionKey: pageCubit.sectionKeys[activeTitle],
          onReviewsSeeAll: salonDetail.reviews.isNotEmpty
              ? () => SalonAllReviewsSheet.show(
                    context,
                    salonDetail: salonDetail,
                    isDarkMode: isDarkMode,
                    initialFilterIndex: pageState.activeReviewFilterIndex,
                  )
              : null,
          servicesSection: SalonServicesSection(
            isDarkMode: isDarkMode,
            salonDetail: salonDetail,
            selectedServices: pageState.selectedServices,
            activeServiceCategoryIndex: pageState.activeServiceCategoryIndex,
            onServiceCategoryChanged: (index) {
              context
                  .read<SalonDetailsPageCubit>()
                  .setServiceCategoryIndex(index);
            },
            onToggleService: _toggleService,
          ),
          teamSection: SalonTeamSection(
            isDarkMode: isDarkMode,
            salonDetail: salonDetail,
          ),
          reviewsSection: SalonReviewsSection(
            isDarkMode: isDarkMode,
            salonDetail: salonDetail,
            activeReviewFilterIndex: pageState.activeReviewFilterIndex,
            onReviewFilterChanged: (index) {
              context.read<SalonDetailsPageCubit>().setReviewFilterIndex(index);
            },
            onSeeAll: salonDetail.reviews.isNotEmpty
                ? () => SalonAllReviewsSheet.show(
                      context,
                      salonDetail: salonDetail,
                      isDarkMode: isDarkMode,
                      initialFilterIndex: pageState.activeReviewFilterIndex,
                    )
                : null,
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}
