import 'package:flutter_test/flutter_test.dart';
import 'package:tressy/features/home/domain/entities/filter_state.dart';

void main() {
  group('FilterState', () {
    test('empty state sends nothing and has no active filters', () {
      expect(FilterState.empty.toRequest(), isEmpty);
      expect(FilterState.empty.activeCount, 0);
      expect(FilterState.empty.isEmpty, isTrue);
    });

    test('toRequest maps sort and filters to backend keys', () {
      const state = FilterState(
        sort: SalonSort.priceLowToHigh,
        gender: GenderFilter.unisex,
        minRating: 4.0,
        minPrice: 100,
        maxPrice: 300,
        hasOffers: true,
      );
      expect(state.toRequest(), {
        'sort': 'price_asc',
        'gender': 'unisex',
        'minRating': 4.0,
        'minPrice': 100,
        'maxPrice': 300,
        'hasOffers': true,
      });
    });

    test('every sort has the expected key', () {
      const keys = {
        SalonSort.relevance: null,
        SalonSort.distance: 'distance',
        SalonSort.rating: 'rating',
        SalonSort.priceLowToHigh: 'price_asc',
        SalonSort.priceHighToLow: 'price_desc',
        SalonSort.earliestSlot: 'earliest_slot',
      };
      keys.forEach((sort, key) {
        expect(FilterState(sort: sort).toRequest()['sort'], key);
      });
    });

    test('activeCount counts price range once and ignores sort', () {
      const state = FilterState(
        sort: SalonSort.rating,
        gender: GenderFilter.male,
        minPrice: 100,
        maxPrice: 300,
        serviceIds: {'2', '1'},
        openNow: true,
      );
      expect(state.activeCount, 4);
      expect(state.isEmpty, isFalse);
      expect(state.toRequest()['serviceIds'], ['1', '2']);
    });

    test('copyWith clear flags remove values', () {
      final state = const FilterState(
        gender: GenderFilter.female,
        minRating: 4.5,
        minPrice: 50,
        maxPrice: 200,
        maxDistanceKm: 3,
      ).copyWith(
        clearGender: true,
        clearMinRating: true,
        clearPrice: true,
        clearMaxDistance: true,
      );
      expect(state, FilterState.empty);
    });

    test('equal states compare equal', () {
      expect(
        const FilterState(serviceIds: {'a'}, hasOffers: true),
        const FilterState(serviceIds: {'a'}, hasOffers: true),
      );
    });
  });
}
