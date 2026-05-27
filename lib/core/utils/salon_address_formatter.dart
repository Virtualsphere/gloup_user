/// Formats full salon addresses into a short "Area, City" label for list cards.
class SalonLocationParts {
  final String area;
  final String city;

  const SalonLocationParts({required this.area, required this.city});

  bool get hasArea => area.trim().isNotEmpty;
  bool get hasCity => city.trim().isNotEmpty;

  /// One-line label for compact rows.
  String get singleLine {
    if (hasArea && hasCity) {
      if (_normalize(area) == _normalize(city)) return city;
      return '$area, $city';
    }
    return hasCity ? city : area;
  }

  static String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

class SalonAddressFormatter {
  SalonAddressFormatter._();

  /// Returns a short location label such as `Gachibowli, Hyderabad`.
  static String areaAndCity(String? rawAddress) {
    return parse(rawAddress).singleLine;
  }

  /// Splits an address into area + city for multi-line card layouts.
  static SalonLocationParts parse(String? rawAddress) {
    if (rawAddress == null || rawAddress.trim().isEmpty) {
      return const SalonLocationParts(area: '', city: 'Not available');
    }

    final parts = rawAddress
        .split(',')
        .map(_cleanSegment)
        .where((e) => e.isNotEmpty && !_isNoise(e))
        .toList();

    if (parts.isEmpty) {
      return const SalonLocationParts(area: '', city: 'Not available');
    }
    if (parts.length == 1) {
      return SalonLocationParts(area: '', city: _capLength(parts.first, 36));
    }

    final city = _capLength(parts.last, 28);
    String? area;

    for (var i = parts.length - 2; i >= 0; i--) {
      if (_looksLikeArea(parts[i])) {
        area = _capLength(parts[i], 28);
        break;
      }
    }

    if (area == null || area.isEmpty) {
      return SalonLocationParts(area: '', city: city);
    }

    return SalonLocationParts(area: area, city: city);
  }

  static String _cleanSegment(String segment) {
    return segment
        .replaceAll(RegExp(r'[-–]\s*\d{5,6}\b'), '')
        .replaceAll(RegExp(r'\b\d{5,6}\b'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool _isNoise(String segment) {
    if (RegExp(r'^\d+$').hasMatch(segment)) return true;

    if (RegExp(r'^[A-Za-z\s]+[-–]\s*\d{5,6}$').hasMatch(segment)) {
      return true;
    }

    if (RegExp(r'\d{5,6}').hasMatch(segment) &&
        segment.replaceAll(RegExp(r'\D'), '').length >= 5) {
      return true;
    }

    if (segment.length > 45) return true;

    return false;
  }

  static bool _looksLikeArea(String segment) {
    if (_isBuildingOrStreet(segment)) return false;
    if (segment.length > 32) return false;
    return true;
  }

  static bool _isBuildingOrStreet(String segment) {
    final lower = segment.toLowerCase();
    const keywords = [
      'nilayam',
      'apartment',
      'apartments',
      'complex',
      'building',
      'bldg',
      'floor',
      'ground floor',
      'plot no',
      'plot',
      'tower',
      'heights',
      'residency',
      'main road',
      'service road',
      ' high road',
      ' road',
      ' street',
      ' st,',
      'near by',
      'near ',
      'opp ',
      'opposite',
      'beside',
      'lane',
      'ward no',
      'sector',
      'shop no',
      'house no',
    ];

    for (final keyword in keywords) {
      if (lower.contains(keyword)) return true;
    }

    if (segment.split(RegExp(r'\s+')).length >= 4) return true;

    return false;
  }

  static String _capLength(String value, int maxChars) {
    if (value.length <= maxChars) return value;
    return '${value.substring(0, maxChars - 1).trim()}…';
  }
}
