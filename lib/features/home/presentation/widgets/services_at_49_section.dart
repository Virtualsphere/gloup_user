import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/utils/category_image_resolver.dart';
import 'package:tressy/features/home/presentation/pages/services_at_49_page.dart';
import 'package:tressy/features/home/presentation/widgets/gender_toggle_widget.dart';
import 'package:tressy/features/home/presentation/widgets/service_card_widget.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

/// Figma Gloup-Onboarding-screens — Frame 4844 / 1912054785.
class ServicesAt49Section extends StatefulWidget {
  const ServicesAt49Section({super.key});

  @override
  State<ServicesAt49Section> createState() => _ServicesAt49SectionState();
}

class _ServicesAt49SectionState extends State<ServicesAt49Section> {
  GenderTab _selectedGender = GenderTab.men;

  bool get _isMenSelected => _selectedGender == GenderTab.men;

  bool _isLoading = true;
  List<ServiceItemData> _menItems = [];
  List<ServiceItemData> _womenItems = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final dio = sl<DioClient>();

      final menRes =
          await dio.post(ApiRoutes.getTopCategories, data: {'sex': 'male'});
      if (menRes.statusCode == 200 && menRes.data['success'] == true) {
        _menItems = _mapItems(menRes.data['data'] as List);
      }

      final womenRes =
          await dio.post(ApiRoutes.getTopCategories, data: {'sex': 'female'});
      if (womenRes.statusCode == 200 && womenRes.data['success'] == true) {
        _womenItems = _mapItems(womenRes.data['data'] as List);
      }
    } catch (e) {
      debugPrint('Error fetching top categories: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ServiceItemData> _mapItems(List data) {
    return data.map((e) {
      final name = e['category_name'].toString();
      return ServiceItemData(
        id: e['category_id'].toString(),
        title: name,
        price: '₹${e['discounted_amount']}',
        imageUrl: CategoryImageResolver.resolveImagePath(
          categoryName: name,
          imageUrl: CategoryImageResolver.apiImageFromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        ),
      );
    }).toList();
  }

  void _openSeeAll() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServicesAt49Page(
          sex: _isMenSelected ? 'male' : 'female',
        ),
      ),
    );
  }

  void _openItem(ServiceItemData item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServicesAt49Page(
          initialCategory: item.title,
          categoryId: item.id,
          sex: _isMenSelected ? 'male' : 'female',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    final theme =
        _isMenSelected ? ServiceCardTheme.men : ServiceCardTheme.women;
    final items = _isMenSelected ? _menItems : _womenItems;

    return Container(
      color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: GenderToggleWidget(
              selected: _selectedGender,
              onChanged: (tab) => setState(() => _selectedGender = tab),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: ServiceCardWidget(
              isMenSelected: _isMenSelected,
              theme: theme,
              subtitle: _isMenSelected ? 'Basics for Men' : 'Basics for Women',
              priceTag: _isMenSelected ? '@₹49' : '@₹9',
              items: items,
              isLoading: _isLoading,
              isDarkMode: isDarkMode,
              onSeeAll: _openSeeAll,
              onItemTap: _openItem,
            ),
          ),
        ],
      ),
    );
  }
}
