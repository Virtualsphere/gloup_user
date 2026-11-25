import 'package:equatable/equatable.dart';

enum SalonSort {
  relevance,
  distance,
  rating,
  priceLowToHigh,
  priceHighToLow,
  earliestSlot,
}

enum GenderFilter { male, female, unisex }

/// Filters and sorting chosen in the Filters sheet (Figma 6-2).
///
/// [toRequest] produces the extra body fields for `POST /v2/store/nearby`.
/// `maxDistanceKm`, `serviceIds`, `openNow` and the earliest-slot sort are
/// sent for forward compatibility; the backend ignores them until it supports them.
class FilterState extends Equatable {
  final SalonSort sort;
  final GenderFilter? gender;
  final double? minRating;
  final int? minPrice;
  final int? maxPrice;
  final bool hasOffers;
  final double? maxDistanceKm;
  final Set<String> serviceIds;
  final bool openNow;

  const FilterState({
    this.sort = SalonSort.relevance,
    this.gender,
    this.minRating,
    this.minPrice,
    this.maxPrice,
    this.hasOffers = false,
    this.maxDistanceKm,
    this.serviceIds = const {},
    this.openNow = false,
  });

  static const FilterState empty = FilterState();

  /// Number of narrowing filters (sort is not a filter); drives the "Filters 2" badge.
  int get activeCount =>
      (gender != null ? 1 : 0) +
      (minRating != null ? 1 : 0) +
      (minPrice != null || maxPrice != null ? 1 : 0) +
      (hasOffers ? 1 : 0) +
      (maxDistanceKm != null ? 1 : 0) +
      (serviceIds.isNotEmpty ? 1 : 0) +
      (openNow ? 1 : 0);

  bool get isEmpty => activeCount == 0 && sort == SalonSort.relevance;

  FilterState copyWith({
    SalonSort? sort,
    GenderFilter? gender,
    double? minRating,
    int? minPrice,
    int? maxPrice,
    bool? hasOffers,
    double? maxDistanceKm,
    Set<String>? serviceIds,
    bool? openNow,
    bool clearGender = false,
    bool clearMinRating = false,
    bool clearPrice = false,
    bool clearMaxDistance = false,
  }) {
    return FilterState(
      sort: sort ?? this.sort,
      gender: clearGender ? null : (gender ?? this.gender),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
      hasOffers: hasOffers ?? this.hasOffers,
      maxDistanceKm:
          clearMaxDistance ? null : (maxDistanceKm ?? this.maxDistanceKm),
      serviceIds: serviceIds ?? this.serviceIds,
      openNow: openNow ?? this.openNow,
    );
  }

  /// Sets the price range; either bound may be null (open ended).
  FilterState withPriceRange(int? min, int? max) => FilterState(
        sort: sort,
        gender: gender,
        minRating: minRating,
        minPrice: min,
        maxPrice: max,
        hasOffers: hasOffers,
        maxDistanceKm: maxDistanceKm,
        serviceIds: serviceIds,
        openNow: openNow,
      );

  String? get _sortKey {
    switch (sort) {
      case SalonSort.relevance:
        return null;
      case SalonSort.distance:
        return 'distance';
      case SalonSort.rating:
        return 'rating';
      case SalonSort.priceLowToHigh:
        return 'price_asc';
      case SalonSort.priceHighToLow:
        return 'price_desc';
      case SalonSort.earliestSlot:
        return 'earliest_slot';
    }
  }

  /// Request fields to merge into the nearby-stores body. Unset filters are omitted.
  Map<String, dynamic> toRequest() {
    return {
      if (_sortKey != null) 'sort': _sortKey,
      if (gender != null) 'gender': gender!.name,
      if (minRating != null) 'minRating': minRating,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (hasOffers) 'hasOffers': true,
      if (maxDistanceKm != null) 'maxDistance': maxDistanceKm,
      if (serviceIds.isNotEmpty) 'serviceIds': (serviceIds.toList()..sort()),
      if (openNow) 'openNow': true,
    };
  }

  @override
  List<Object?> get props => [
        sort,
        gender,
        minRating,
        minPrice,
        maxPrice,
        hasOffers,
        maxDistanceKm,
        serviceIds,
        openNow,
      ];
}
