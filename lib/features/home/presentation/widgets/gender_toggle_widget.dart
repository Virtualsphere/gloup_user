import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/app_colors.dart';

enum GenderTab { men, women }

/// Floating tab header — Figma Frame 1912054785 (378×44, 189 per tab).
///
/// Attaches flush to [ServiceCardWidget] below. Unselected tab is transparent.
class GenderToggleWidget extends StatefulWidget {
  const GenderToggleWidget({
    super.key,
    this.selected,
    this.initialSelection = GenderTab.men,
    this.onChanged,
    this.height = defaultHeight,
  });

  static const defaultHeight = 44.0;
  static const designWidth = 378.0;
  static const tabDesignWidth = 189.0;

  final GenderTab? selected;
  final GenderTab initialSelection;
  final ValueChanged<GenderTab>? onChanged;
  final double height;

  @override
  State<GenderToggleWidget> createState() => _GenderToggleWidgetState();
}

class _GenderToggleWidgetState extends State<GenderToggleWidget> {
  late GenderTab _internalSelection;

  GenderTab get _current => widget.selected ?? _internalSelection;

  @override
  void initState() {
    super.initState();
    _internalSelection = widget.selected ?? widget.initialSelection;
  }

  @override
  void didUpdateWidget(covariant GenderToggleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != null) return;
    if (oldWidget.initialSelection != widget.initialSelection) {
      _internalSelection = widget.initialSelection;
    }
  }

  void _select(GenderTab tab) {
    if (_current == tab) return;
    if (widget.selected == null) setState(() => _internalSelection = tab);
    widget.onChanged?.call(tab);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _current;

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _GenderTab(
              label: 'MEN',
              isSelected: selected == GenderTab.men,
              isLeft: true,
              height: widget.height,
              selectedBackground: const Color(0xFFEEF3F6),
              borderColor: Color(0xFFBFDFF5).withValues(alpha: 0.35),
              accentColor: const Color(0xFF1485E0),
              glowColor: const Color(0xFF1485E0).withValues(alpha: 0.12),
              onTap: () => _select(GenderTab.men),
            ),
          ),
          Expanded(
            child: _GenderTab(
              label: 'WOMEN',
              isSelected: selected == GenderTab.women,
              isLeft: false,
              height: widget.height,
              selectedGradient: const LinearGradient(
                colors: [
                  Color(0xFFF4F0F8),
                  Color(0xFFEDE6F2),
                  Color(0xFFF4F0F8),
                ],
                stops: [0.0, 0.5, 1.0],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderColor: const Color.fromRGBO(104, 93, 220, 0.08),
              accentColor: const Color(0xFF6A5AE0),
              glowColor: const Color.fromRGBO(196, 0, 255, 0.20),
              onTap: () => _select(GenderTab.women),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderTab extends StatelessWidget {
  const _GenderTab({
    required this.label,
    required this.isSelected,
    required this.isLeft,
    required this.height,
    this.selectedBackground,
    this.selectedGradient,
    required this.borderColor,
    required this.accentColor,
    required this.glowColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isLeft;
  final double height;
  final Color? selectedBackground;
  final Gradient? selectedGradient;
  final Color borderColor;
  final Color accentColor;
  final Color glowColor;
  final VoidCallback onTap;

  BorderRadius get _radius => BorderRadius.only(
        topLeft: Radius.circular(isLeft ? 13 : 30),
        topRight: Radius.circular(isLeft ? 30 : 13),
      );

  @override
  Widget build(BuildContext context) {
    if (!isSelected) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: height,
          color: AppColors.transparent,
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 15 / 12,
              color: AppColors.genderTabUnselectedText,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / GenderToggleWidget.tabDesignWidth;
        const glowW = 96.0;
        const glowH = 46.0;
        final glowLeft = isLeft
            ? -8.0 * scale
            : constraints.maxWidth - (glowW * scale) + (8.0 * scale);

        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: height,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: selectedBackground,
              gradient: selectedGradient,
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
              borderRadius: _radius,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                Positioned(
                  left: glowLeft,
                  top: -6,
                  child: IgnorePointer(
                    child: Container(
                      width: glowW * scale,
                      height: glowH,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: glowColor,
                            blurRadius: 90,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 15 / 12,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
