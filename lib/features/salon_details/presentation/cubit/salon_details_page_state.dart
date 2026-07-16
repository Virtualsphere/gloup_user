import 'package:equatable/equatable.dart';
import 'package:tressy/features/salon_details/domain/entities/salon_detail_entity.dart';

class SalonDetailsPageState extends Equatable {
  final int activeTabIndex;
  final int activeServiceCategoryIndex;
  final int activeReviewFilterIndex;
  final int currentImageIndex;
  final bool isCollapsed;
  final Map<int, ServiceEntity> selectedServices;

  const SalonDetailsPageState({
    this.activeTabIndex = 0,
    this.activeServiceCategoryIndex = 0,
    this.activeReviewFilterIndex = 0,
    this.currentImageIndex = 0,
    this.isCollapsed = false,
    this.selectedServices = const {},
  });

  SalonDetailsPageState copyWith({
    int? activeTabIndex,
    int? activeServiceCategoryIndex,
    int? activeReviewFilterIndex,
    int? currentImageIndex,
    bool? isCollapsed,
    Map<int, ServiceEntity>? selectedServices,
  }) {
    return SalonDetailsPageState(
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      activeServiceCategoryIndex:
          activeServiceCategoryIndex ?? this.activeServiceCategoryIndex,
      activeReviewFilterIndex:
          activeReviewFilterIndex ?? this.activeReviewFilterIndex,
      currentImageIndex: currentImageIndex ?? this.currentImageIndex,
      isCollapsed: isCollapsed ?? this.isCollapsed,
      selectedServices: selectedServices ?? this.selectedServices,
    );
  }

  @override
  List<Object?> get props => [
        activeTabIndex,
        activeServiceCategoryIndex,
        activeReviewFilterIndex,
        currentImageIndex,
        isCollapsed,
        selectedServices,
      ];
}
