import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/features/salon_details/domain/entities/salon_detail_entity.dart';
import 'package:tressy/features/salon_details/presentation/cubit/salon_details_page_state.dart';

class SalonDetailsPageCubit extends Cubit<SalonDetailsPageState> {
  SalonDetailsPageCubit() : super(const SalonDetailsPageState());

  final List<String> tabs = const [
    'Services',
    'About',
    'Amenities',
    'Team',
    'Reviews',
    'Opening Hours',
    'Location',
  ];

  final Map<String, GlobalKey> sectionKeys = {
    'Services': GlobalKey(),
    'About': GlobalKey(),
    'Amenities': GlobalKey(),
    'Team': GlobalKey(),
    'Reviews': GlobalKey(),
    'Opening Hours': GlobalKey(),
    'Location': GlobalKey(),
  };

  void setCollapsed(bool value) {
    if (state.isCollapsed == value) return;
    emit(state.copyWith(isCollapsed: value));
  }

  void setActiveTab(int index) {
    if (state.activeTabIndex == index) return;
    emit(state.copyWith(activeTabIndex: index));
  }

  void setServiceCategoryIndex(int index) {
    if (state.activeServiceCategoryIndex == index) return;
    emit(state.copyWith(activeServiceCategoryIndex: index));
  }

  void setReviewFilterIndex(int index) {
    if (state.activeReviewFilterIndex == index) return;
    emit(state.copyWith(activeReviewFilterIndex: index));
  }

  void setImageIndex(int index) {
    if (state.currentImageIndex == index) return;
    emit(state.copyWith(currentImageIndex: index));
  }

  void toggleService(ServiceEntity service) {
    final updated = Map<int, ServiceEntity>.from(state.selectedServices);
    if (updated.containsKey(service.id)) {
      updated.remove(service.id);
    } else {
      updated[service.id] = service;
    }
    emit(state.copyWith(selectedServices: updated));
  }

  double get totalPrice => state.selectedServices.values
      .fold(0.0, (sum, service) => sum + service.price);

  int get serviceCount => state.selectedServices.length;

  int get highestOfferPercentage {
    if (state.selectedServices.isEmpty) return 0;
    return state.selectedServices.values
        .where((service) => service.discountPercentage != null)
        .map((service) {
      final discountStr = service.discountPercentage!;
      return int.tryParse(discountStr.replaceAll('%', '').trim()) ?? 0;
    }).fold<int>(0, (max, discount) => discount > max ? discount : max);
  }

  static Map<int, int> calculateStarCounts(List<ReviewEntity> reviews) {
    final counts = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final review in reviews) {
      final rating = review.rating.round();
      if (rating >= 1 && rating <= 5) {
        counts[rating] = (counts[rating] ?? 0) + 1;
      }
    }
    return counts;
  }

  static List<String> getUniqueCategories(List<ServiceEntity> services) {
    final categories = services
        .map((service) => service.category)
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }
}
