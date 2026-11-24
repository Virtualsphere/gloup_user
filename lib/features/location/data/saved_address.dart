import 'dart:convert';

import 'package:tressy/core/utils/local_storage_service.dart';

enum SavedAddressLabel { home, work, other }

extension SavedAddressLabelX on SavedAddressLabel {
  String get title => switch (this) {
        SavedAddressLabel.home => 'Home',
        SavedAddressLabel.work => 'Work',
        SavedAddressLabel.other => 'Other',
      };
}

/// A user-saved address (Figma 21b / 21c). Stored on device only.
class SavedAddress {
  final String id;
  final SavedAddressLabel label;

  /// Custom name for [SavedAddressLabel.other], e.g. "Mom's place".
  final String? name;
  final String flat;
  final String? landmark;

  /// Street-level line from reverse geocoding, e.g. "3rd Main Road, Anna Nagar".
  final String street;

  /// Locality used for the home location badge, e.g. "Anna Nagar".
  final String area;
  final String city;

  /// Region line, e.g. "Chennai, Tamil Nadu 600040".
  final String region;
  final double latitude;
  final double longitude;

  const SavedAddress({
    required this.id,
    required this.label,
    this.name,
    required this.flat,
    this.landmark,
    required this.street,
    required this.area,
    required this.city,
    required this.region,
    required this.latitude,
    required this.longitude,
  });

  String get title =>
      (name != null && name!.trim().isNotEmpty) ? name!.trim() : label.title;

  /// Single line shown on the saved-address card.
  String get fullLine => [
        flat,
        if (landmark != null && landmark!.isNotEmpty) landmark!,
        street,
        if (city.isNotEmpty && !street.contains(city)) city,
      ].where((e) => e.trim().isNotEmpty).join(', ');

  /// Result shape returned by LocationPage when this address is picked.
  Map<String, dynamic> toLocationResult() => {
        'city': city,
        'area': area,
        'latitude': latitude,
        'longitude': longitude,
      };

  SavedAddress copyWith({
    SavedAddressLabel? label,
    String? name,
    String? flat,
    String? landmark,
    String? street,
    String? area,
    String? city,
    String? region,
    double? latitude,
    double? longitude,
  }) {
    return SavedAddress(
      id: id,
      label: label ?? this.label,
      name: name ?? this.name,
      flat: flat ?? this.flat,
      landmark: landmark ?? this.landmark,
      street: street ?? this.street,
      area: area ?? this.area,
      city: city ?? this.city,
      region: region ?? this.region,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label.name,
        'name': name,
        'flat': flat,
        'landmark': landmark,
        'street': street,
        'area': area,
        'city': city,
        'region': region,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: json['id'].toString(),
      label: SavedAddressLabel.values.firstWhere(
        (l) => l.name == json['label'],
        orElse: () => SavedAddressLabel.other,
      ),
      name: json['name']?.toString(),
      flat: json['flat']?.toString() ?? '',
      landmark: json['landmark']?.toString(),
      street: json['street']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

/// Persists saved addresses in SharedPreferences (cleared on logout with the
/// rest of local storage).
class SavedAddressStore {
  SavedAddressStore._();

  static const String _key = 'saved_addresses_v1';

  static List<SavedAddress> load() {
    final raw = LocalStorageService.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List;
      return list
          .whereType<Map>()
          .map((e) => SavedAddress.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _write(List<SavedAddress> addresses) =>
      LocalStorageService.setString(
        _key,
        json.encode(addresses.map((a) => a.toJson()).toList()),
      );

  /// Inserts a new address or replaces the one with the same id.
  static Future<List<SavedAddress>> upsert(SavedAddress address) async {
    final list = load();
    final index = list.indexWhere((a) => a.id == address.id);
    if (index >= 0) {
      list[index] = address;
    } else {
      list.add(address);
    }
    list.sort((a, b) => a.label.index.compareTo(b.label.index));
    await _write(list);
    return list;
  }

  static Future<List<SavedAddress>> remove(String id) async {
    final list = load()..removeWhere((a) => a.id == id);
    await _write(list);
    return list;
  }

  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();
}
