import 'package:equatable/equatable.dart';

/// Best discount on a salon, shown as the card badge ("50% OFF", "FLAT ₹150 OFF").
///
/// Mirrors the backend `offerBadge` field on salon objects.
class OfferBadge extends Equatable {
  final int percent;
  final int flat;
  final String label;
  final String? serviceName;

  const OfferBadge({
    required this.percent,
    required this.flat,
    required this.label,
    this.serviceName,
  });

  /// Parses the backend payload; returns null for missing or empty badges.
  static OfferBadge? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final percent = (raw['percent'] as num?)?.round() ?? 0;
    final flat = (raw['flat'] as num?)?.round() ?? 0;
    if (percent <= 0 && flat <= 0) return null;

    final label = raw['label']?.toString().trim() ?? '';
    return OfferBadge(
      percent: percent,
      flat: flat,
      label: label.isNotEmpty ? label : '$percent% OFF',
      serviceName: raw['serviceName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'percent': percent,
        'flat': flat,
        'label': label,
        'serviceName': serviceName,
      };

  @override
  List<Object?> get props => [percent, flat, label, serviceName];
}
