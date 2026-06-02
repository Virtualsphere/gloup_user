import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/utils/salon_address_formatter.dart';
import 'package:tressy/shared/widgets/responsive_ellipsis_text.dart';

/// Responsive location + distance row for salon cards.
class SalonLocationRow extends StatelessWidget {
  const SalonLocationRow({
    super.key,
    required this.locationLabel,
    this.distanceKm,
    this.showDistance = true,
    this.isDarkMode = false,
    this.useTwoLines = false,
  });

  /// Pre-formatted `displayAddress` or raw address (parsed internally).
  final String? locationLabel;
  final double? distanceKm;
  final bool showDistance;
  final bool isDarkMode;
  final bool useTwoLines;

  @override
  Widget build(BuildContext context) {
    final parts = SalonAddressFormatter.parse(locationLabel);
    final secondaryColor =
        isDarkMode ? AppColors.textSecondaryDark : const Color(0xFF737373);
    
    final locationStyle = GoogleFonts.inter(
      color: secondaryColor,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 17 / 14,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          AppIcons.icLocation,
          width: 14,
          height: 16,
          colorFilter: ColorFilter.mode(
            secondaryColor,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: ResponsiveEllipsisText(
            text: parts.singleLine,
            style: locationStyle,
            maxLines: 1,
          ),
        ),
        if (showDistance && distanceKm != null) ...[
          const SizedBox(width: 8),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: secondaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${distanceKm!.toStringAsFixed(1)} km',
            style: GoogleFonts.inter(
              color: secondaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 17 / 14,
            ),
          ),
        ],
      ],
    );
  }
}
