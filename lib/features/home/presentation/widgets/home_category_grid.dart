import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/home_design_tokens.dart';
import 'package:tressy/features/category/domain/entities/category_entity.dart';
import 'package:tressy/shared/widgets/category_image.dart';

/// "What are you looking for?" 4×2 grid (Figma 3-2).
class HomeCategoryGrid extends StatelessWidget {
  static const int maxItems = 8;
  static const int columns = 4;

  final List<CategoryEntity> categories;
  final bool isLoading;
  final String? error;
  final void Function(CategoryEntity category, int index) onCategoryTap;
  final VoidCallback onSeeAll;
  final VoidCallback? onRetry;

  const HomeCategoryGrid({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    required this.onSeeAll,
    this.isLoading = false,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final shown = categories.take(maxItems).toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        HomeDesignTokens.screenGutter.w,
        8.h,
        HomeDesignTokens.screenGutter.w,
        8.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'What are you looking for?',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: HomeDesignTokens.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                key: const Key('category_see_all'),
                behavior: HitTestBehavior.opaque,
                onTap: onSeeAll,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Text(
                    'See all',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: HomeDesignTokens.accentBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (isLoading && shown.isEmpty)
            _skeleton()
          else if (error != null && shown.isEmpty)
            _error()
          else if (shown.isEmpty)
            const SizedBox.shrink()
          else
            _grid(shown),
        ],
      ),
    );
  }

  Widget _grid(List<CategoryEntity> items) {
    return GridView.builder(
      key: const Key('category_grid'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 14.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, i) {
        final c = items[i];
        return GestureDetector(
          key: Key('category_$i'),
          behavior: HitTestBehavior.opaque,
          onTap: () => onCategoryTap(c, i),
          child: Column(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(HomeDesignTokens.tileRadius.r),
                    child: ColoredBox(
                      color: HomeDesignTokens.pageBackground,
                      child: CategoryImage(
                        categoryName: c.label,
                        imageUrl: c.imageUrl,
                        apiCategories: categories,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                c.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: HomeDesignTokens.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _skeleton() {
    return GridView.builder(
      key: const Key('category_skeleton'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: maxItems,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 14.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: HomeDesignTokens.border,
          borderRadius: BorderRadius.circular(HomeDesignTokens.tileRadius.r),
        ),
      ),
    );
  }

  Widget _error() {
    return Row(
      key: const Key('category_error'),
      children: [
        Expanded(
          child: Text(
            "Couldn't load categories",
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: HomeDesignTokens.textSecondary,
            ),
          ),
        ),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
