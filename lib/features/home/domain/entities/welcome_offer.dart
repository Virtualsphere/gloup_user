import 'package:equatable/equatable.dart';

/// First-booking offer from `GET /v2/home/welcome-offer` (Figma 4-2).
class WelcomeOffer extends Equatable {
  final int couponId;
  final String code;
  final String title;
  final String? description;

  /// End of the offer window; null when it has no deadline.
  final DateTime? validUntil;

  const WelcomeOffer({
    required this.couponId,
    required this.code,
    required this.title,
    this.description,
    this.validUntil,
  });

  /// Countdown is only shown for offers about to lapse.
  static const countdownThreshold = Duration(hours: 6);

  /// Parses the API payload; null when the offer or its code is missing.
  static WelcomeOffer? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final code = raw['code']?.toString().trim() ?? '';
    final id = (raw['couponId'] as num?)?.toInt();
    if (code.isEmpty || id == null) return null;

    final title = raw['title']?.toString().trim() ?? '';
    final description = raw['description']?.toString().trim();
    return WelcomeOffer(
      couponId: id,
      code: code,
      title: title.isNotEmpty ? title : 'Welcome gift',
      description:
          description == null || description.isEmpty ? null : description,
      validUntil: DateTime.tryParse(raw['validUntil']?.toString() ?? ''),
    );
  }

  Duration? remaining(DateTime now) => validUntil?.difference(now);

  bool isExpired(DateTime now) {
    final left = remaining(now);
    return left != null && left <= Duration.zero;
  }

  bool showCountdown(DateTime now) {
    final left = remaining(now);
    return left != null && left > Duration.zero && left < countdownThreshold;
  }

  /// "5h 12m left", "42m left" or "Less than a minute left".
  static String formatCountdown(Duration left) {
    if (left.inMinutes < 1) return 'Less than a minute left';
    final h = left.inHours;
    final m = left.inMinutes % 60;
    return h > 0 ? '${h}h ${m}m left' : '${m}m left';
  }

  /// Stored once the pop-up was shown, so it appears once per offer window.
  String get shownKey => '$couponId|${validUntil?.toIso8601String() ?? ''}';

  @override
  List<Object?> get props => [couponId, code, title, description, validUntil];
}
