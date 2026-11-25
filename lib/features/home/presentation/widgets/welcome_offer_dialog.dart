import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/home_design_tokens.dart';
import 'package:tressy/features/home/domain/entities/welcome_offer.dart';
import 'package:tressy/shared/widgets/custom_toast.dart';

/// Welcome gift pop-up (Figma 4-2).
class WelcomeOfferDialog extends StatefulWidget {
  final WelcomeOffer offer;
  final VoidCallback onBookSalon;
  final VoidCallback onTerms;

  /// Clock, injectable for tests.
  final DateTime Function() now;

  const WelcomeOfferDialog({
    super.key,
    required this.offer,
    required this.onBookSalon,
    required this.onTerms,
    this.now = DateTime.now,
  });

  /// Returns once dismissed. Callbacks run after the dialog has closed.
  static Future<void> show(
    BuildContext context, {
    required WelcomeOffer offer,
    required VoidCallback onBookSalon,
    required VoidCallback onTerms,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: HomeDesignTokens.modalScrim,
      builder: (_) => WelcomeOfferDialog(
        offer: offer,
        onBookSalon: onBookSalon,
        onTerms: onTerms,
      ),
    );
  }

  @override
  State<WelcomeOfferDialog> createState() => _WelcomeOfferDialogState();
}

class _WelcomeOfferDialogState extends State<WelcomeOfferDialog> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    if (widget.offer.showCountdown(widget.now())) {
      _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.offer.code));
    if (!mounted) return;
    CustomToast.showSuccess(context, 'Code ${widget.offer.code} copied');
  }

  void _close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final left = offer.remaining(widget.now());
    final countdown = offer.showCountdown(widget.now()) && left != null
        ? WelcomeOffer.formatCountdown(left)
        : null;

    return Dialog(
      backgroundColor: HomeDesignTokens.surface,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  key: const Key('welcome_close'),
                  icon: const Icon(Icons.close_rounded),
                  onPressed: _close,
                ),
              ),
              Container(
                width: 88.w,
                height: 88.w,
                decoration: const BoxDecoration(
                  color: HomeDesignTokens.accentBlueBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  size: 44.w,
                  color: HomeDesignTokens.accentBlue,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'WELCOME GIFT',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: HomeDesignTokens.accentBlue,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                offer.title,
                key: const Key('welcome_title'),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: HomeDesignTokens.textPrimary,
                ),
              ),
              if (offer.description != null) ...[
                SizedBox(height: 8.h),
                Text(
                  offer.description!,
                  key: const Key('welcome_description'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: HomeDesignTokens.textSecondary,
                  ),
                ),
              ],
              if (countdown != null) ...[
                SizedBox(height: 8.h),
                Text(
                  countdown,
                  key: const Key('welcome_countdown'),
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
              SizedBox(height: 16.h),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: HomeDesignTokens.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        offer.code,
                        key: const Key('welcome_code'),
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: HomeDesignTokens.textPrimary,
                        ),
                      ),
                    ),
                    TextButton(
                      key: const Key('welcome_copy'),
                      onPressed: _copy,
                      child: Text(
                        'Copy',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: HomeDesignTokens.accentBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  key: const Key('welcome_book'),
                  onPressed: () {
                    _close();
                    widget.onBookSalon();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeDesignTokens.textPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Book a salon',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              TextButton(
                key: const Key('welcome_terms'),
                onPressed: widget.onTerms,
                child: Text(
                  'T&C apply',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: HomeDesignTokens.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
