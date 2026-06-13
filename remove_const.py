import os
import re

files_to_fix = [
    'lib/core/theme/app_theme.dart',
    'lib/features/booking_confirmation/presentation/pages/review_confirm_page.dart',
    'lib/features/home/presentation/pages/home_page.dart',
    'lib/features/home/presentation/pages/services_at_49_page.dart',
    'lib/features/home/presentation/widgets/location_badge.dart',
    'lib/features/profile/presentation/pages/profile_page.dart',
    'lib/features/salon_search/presentation/widgets/salon_search_card.dart',
    'lib/features/slot_booking/presentation/pages/slot_booking_page.dart',
    'lib/features/slot_booking/presentation/widgets/slot_shimmers.dart',
    'lib/shared/widgets/error_widget.dart',
]

for file in files_to_fix:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # We want to blindly replace `const Icon(` with `Icon(`, `const Padding(` with `Padding(`, 
    # `const DividerThemeData(` with `DividerThemeData(`, `const IconThemeData(` with `IconThemeData(`, 
    # `const SizedBox(` with `SizedBox(`, `const SliverGridDelegateWithFixedCrossAxisCount(` with `SliverGridDelegateWithFixedCrossAxisCount(`
    # ONLY if they contain AppSizes in the block.
    # Actually, it's safer to just remove all these consts in these specific files entirely if they have AppSizes, 
    # or just remove `const ` in front of these specific widget/class names globally in these files since we are fixing remaining issues.
    content = content.replace('const DividerThemeData(', 'DividerThemeData(')
    content = content.replace('const IconThemeData(', 'IconThemeData(')
    content = content.replace('const Padding(', 'Padding(')
    content = content.replace('const Icon(', 'Icon(')
    content = content.replace('const SizedBox(', 'SizedBox(')
    content = content.replace('const SliverGridDelegateWithFixedCrossAxisCount(', 'SliverGridDelegateWithFixedCrossAxisCount(')

    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)
