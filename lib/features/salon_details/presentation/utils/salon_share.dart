import 'package:share_plus/share_plus.dart';
import 'package:tressy/features/salon_details/domain/entities/salon_detail_entity.dart';

/// Shares a salon listing via the platform share sheet.
class SalonShare {
  SalonShare._();

  static Future<void> shareSalon(SalonDetailEntity salon) async {
    final rating = salon.rating.toStringAsFixed(1);
    final text = StringBuffer()
      ..writeln('Check out ${salon.name} on GloUp!')
      ..writeln('$rating★ · ${salon.reviewCount} reviews')
      ..writeln(salon.address);

    await SharePlus.instance.share(ShareParams(text: text.toString().trim()));
  }
}
