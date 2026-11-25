import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/home_design_tokens.dart';
import 'package:tressy/features/home/domain/entities/filter_state.dart';

enum FilterPane { sort, gender, rating, distance, price, offers }

/// Filters and sorting bottom sheet (Figma 6-2): left rail with a dot on tabs
/// that have a selection, the active pane on the right, quick picks on top and
/// a footer with Clear all and a live "Show N salons" button.
///
/// Only panes the list endpoint can honour are shown: Services and Open now
/// need backend data that does not exist yet.
class FiltersSheet extends StatefulWidget {
  final FilterState initial;

  /// Number of salons matching a draft filter; null while unknown or on error.
  final Future<int?> Function(FilterState draft) countFor;

  @visibleForTesting
  final Duration debounce;

  const FiltersSheet({
    super.key,
    required this.initial,
    required this.countFor,
    this.debounce = const Duration(milliseconds: 350),
  });

  static const sortOptions = <SalonSort, String>{
    SalonSort.relevance: 'Relevance',
    SalonSort.distance: 'Distance: nearest first',
    SalonSort.rating: 'Rating: high to low',
    SalonSort.priceLowToHigh: 'Price: low to high',
    SalonSort.priceHighToLow: 'Price: high to low',
  };

  static const ratingOptions = <double>[3.0, 3.5, 4.0, 4.5];
  static const distanceOptions = <double>[1, 2, 5, 10];

  /// (label, min, max) in rupees; null bound = open ended.
  static const priceOptions = <(String, int?, int?)>[
    ('Under ₹300', null, 300),
    ('₹300 – ₹600', 300, 600),
    ('₹600 – ₹1000', 600, 1000),
    ('Above ₹1000', 1000, null),
  ];

  static const paneLabels = <FilterPane, String>{
    FilterPane.sort: 'Sort by',
    FilterPane.gender: 'Gender',
    FilterPane.rating: 'Rating',
    FilterPane.distance: 'Distance',
    FilterPane.price: 'Price',
    FilterPane.offers: 'Offers',
  };

  /// Whether a pane has a non-default selection (drives the rail dot).
  /// Sort is not a filter, so it never shows a dot.
  static bool paneHasSelection(FilterPane pane, FilterState f) {
    switch (pane) {
      case FilterPane.sort:
        return false;
      case FilterPane.gender:
        return f.gender != null;
      case FilterPane.rating:
        return f.minRating != null;
      case FilterPane.distance:
        return f.maxDistanceKm != null;
      case FilterPane.price:
        return f.minPrice != null || f.maxPrice != null;
      case FilterPane.offers:
        return f.hasOffers;
    }
  }

  static Future<FilterState?> show(
    BuildContext context, {
    required FilterState initial,
    required Future<int?> Function(FilterState draft) countFor,
  }) {
    return showModalBottomSheet<FilterState>(
      context: context,
      isScrollControlled: true,
      backgroundColor: HomeDesignTokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(HomeDesignTokens.sheetTopRadius.r),
        ),
      ),
      builder: (_) => FiltersSheet(initial: initial, countFor: countFor),
    );
  }

  @override
  State<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<FiltersSheet> {
  late FilterState _draft = widget.initial;
  FilterPane _pane = FilterPane.sort;
  int? _count;
  bool _counting = true;
  Timer? _timer;
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    _refreshCount(immediate: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _update(FilterState next) {
    if (next == _draft) return;
    setState(() {
      _draft = next;
      _counting = true;
    });
    _refreshCount();
  }

  void _refreshCount({bool immediate = false}) {
    _timer?.cancel();
    final seq = ++_seq;
    Future<void> run() async {
      int? count;
      try {
        count = await widget.countFor(_draft);
      } catch (_) {
        count = null;
      }
      // A newer edit superseded this request.
      if (!mounted || seq != _seq) return;
      setState(() {
        _count = count;
        _counting = false;
      });
    }

    if (immediate) {
      run();
    } else {
      _timer = Timer(widget.debounce, run);
    }
  }

  String get _showLabel {
    if (_counting && _count == null) return 'Show salons';
    final n = _count;
    if (n == null) return 'Show salons';
    return n == 1 ? 'Show 1 salon' : 'Show $n salons';
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.85;

    return SafeArea(
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            _header(context),
            _quickPicks(),
            const Divider(height: 1, color: HomeDesignTokens.border),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _rail(),
                  const VerticalDivider(
                      width: 1, color: HomeDesignTokens.border),
                  Expanded(child: _paneBody()),
                ],
              ),
            ),
            const Divider(height: 1, color: HomeDesignTokens.border),
            _footer(context),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 8.w, 4.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Filters and sorting',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: HomeDesignTokens.textPrimary,
              ),
            ),
          ),
          IconButton(
            key: const Key('filters_close'),
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _quickPicks() {
    final topRated = _draft.minRating == 4.0;
    final unisex = _draft.gender == GenderFilter.unisex;
    final under300 = _draft.minPrice == null && _draft.maxPrice == 300;

    return SizedBox(
      height: 44.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        child: Row(
          children: [
            _QuickChip(
              key: const Key('quick_rating'),
              label: 'Rating 4.0+',
              selected: topRated,
              onTap: () => _update(topRated
                  ? _draft.copyWith(clearMinRating: true)
                  : _draft.copyWith(minRating: 4.0)),
            ),
            _QuickChip(
              key: const Key('quick_unisex'),
              label: 'Unisex',
              selected: unisex,
              onTap: () => _update(unisex
                  ? _draft.copyWith(clearGender: true)
                  : _draft.copyWith(gender: GenderFilter.unisex)),
            ),
            _QuickChip(
              key: const Key('quick_under_300'),
              label: 'Under ₹300',
              selected: under300,
              onTap: () =>
                  _update(_draft.withPriceRange(null, under300 ? null : 300)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rail() {
    return SizedBox(
      width: 112.w,
      child: ListView(
        children: [
          for (final pane in FilterPane.values)
            InkWell(
              key: Key('rail_${pane.name}'),
              onTap: () => setState(() => _pane = pane),
              child: Container(
                color: pane == _pane
                    ? HomeDesignTokens.pageBackground
                    : Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        FiltersSheet.paneLabels[pane]!,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight:
                              pane == _pane ? FontWeight.w700 : FontWeight.w500,
                          color: HomeDesignTokens.textPrimary,
                        ),
                      ),
                    ),
                    if (FiltersSheet.paneHasSelection(pane, _draft))
                      Container(
                        key: Key('dot_${pane.name}'),
                        width: 7.w,
                        height: 7.w,
                        decoration: const BoxDecoration(
                          color: HomeDesignTokens.accentBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _paneBody() {
    final List<Widget> options;
    switch (_pane) {
      case FilterPane.sort:
        options = [
          for (final e in FiltersSheet.sortOptions.entries)
            _Option(
              key: Key('sort_${e.key.name}'),
              label: e.value,
              selected: _draft.sort == e.key,
              onTap: () => _update(_draft.copyWith(sort: e.key)),
            ),
        ];
      case FilterPane.gender:
        options = [
          _Option(
            key: const Key('gender_any'),
            label: 'Any',
            selected: _draft.gender == null,
            onTap: () => _update(_draft.copyWith(clearGender: true)),
          ),
          for (final g in GenderFilter.values)
            _Option(
              key: Key('gender_${g.name}'),
              label: g.name[0].toUpperCase() + g.name.substring(1),
              selected: _draft.gender == g,
              onTap: () => _update(_draft.copyWith(gender: g)),
            ),
        ];
      case FilterPane.rating:
        options = [
          _Option(
            key: const Key('rating_any'),
            label: 'Any',
            selected: _draft.minRating == null,
            onTap: () => _update(_draft.copyWith(clearMinRating: true)),
          ),
          for (final r in FiltersSheet.ratingOptions)
            _Option(
              key: Key('rating_$r'),
              label: '${r.toStringAsFixed(1)}+',
              selected: _draft.minRating == r,
              onTap: () => _update(_draft.copyWith(minRating: r)),
            ),
        ];
      case FilterPane.distance:
        options = [
          _Option(
            key: const Key('distance_any'),
            label: 'Any distance',
            selected: _draft.maxDistanceKm == null,
            onTap: () => _update(_draft.copyWith(clearMaxDistance: true)),
          ),
          for (final d in FiltersSheet.distanceOptions)
            _Option(
              key: Key('distance_${d.toInt()}'),
              label: 'Within ${d.toInt()} km',
              selected: _draft.maxDistanceKm == d,
              onTap: () => _update(_draft.copyWith(maxDistanceKm: d)),
            ),
        ];
      case FilterPane.price:
        options = [
          _Option(
            key: const Key('price_any'),
            label: 'Any price',
            selected: _draft.minPrice == null && _draft.maxPrice == null,
            onTap: () => _update(_draft.copyWith(clearPrice: true)),
          ),
          for (var i = 0; i < FiltersSheet.priceOptions.length; i++)
            _Option(
              key: Key('price_$i'),
              label: FiltersSheet.priceOptions[i].$1,
              selected: _draft.minPrice == FiltersSheet.priceOptions[i].$2 &&
                  _draft.maxPrice == FiltersSheet.priceOptions[i].$3,
              onTap: () => _update(_draft.withPriceRange(
                FiltersSheet.priceOptions[i].$2,
                FiltersSheet.priceOptions[i].$3,
              )),
            ),
        ];
      case FilterPane.offers:
        options = [
          SwitchListTile(
            key: const Key('offers_switch'),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
            title: Text(
              'Only salons with offers',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: HomeDesignTokens.textPrimary,
              ),
            ),
            value: _draft.hasOffers,
            onChanged: (v) => _update(_draft.copyWith(hasOffers: v)),
          ),
        ];
    }
    return ListView(children: options);
  }

  Widget _footer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      child: Row(
        children: [
          TextButton(
            key: const Key('filters_clear'),
            onPressed: _draft.isEmpty ? null : () => _update(FilterState.empty),
            child: Text(
              'Clear all',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: SizedBox(
              height: 48.h,
              child: ElevatedButton(
                key: const Key('filters_apply'),
                onPressed: (_count == 0 && !_counting)
                    ? null
                    : () => Navigator.of(context).pop(_draft),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomeDesignTokens.textPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  _showLabel,
                  key: const Key('filters_show_label'),
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Option({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: HomeDesignTokens.textPrimary,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: HomeDesignTokens.accentBlue)
          : null,
      onTap: onTap,
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _QuickChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg =
        selected ? HomeDesignTokens.accentBlue : HomeDesignTokens.textPrimary;
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: selected
                ? HomeDesignTokens.accentBlueBg
                : HomeDesignTokens.surface,
            borderRadius: BorderRadius.circular(HomeDesignTokens.chipRadius.r),
            border: Border.all(
              color: selected
                  ? HomeDesignTokens.accentBlue
                  : HomeDesignTokens.border,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
