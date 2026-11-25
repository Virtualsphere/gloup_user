import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/home/domain/entities/home_gender.dart';

/// Remembers the Home gender controls between launches.
abstract final class HomeGenderStore {
  static const _keyTab = 'home_gender_tab';
  static const _keyUnisex = 'home_gender_include_unisex';

  static HomeGender load() {
    final tabName = LocalStorageService.getString(_keyTab);
    return HomeGender(
      tab: HomeGenderTab.values.firstWhere(
        (t) => t.name == tabName,
        orElse: () => HomeGenderTab.male,
      ),
      includeUnisex: LocalStorageService.getBool(_keyUnisex) ?? true,
    );
  }

  static Future<void> save(HomeGender value) async {
    await LocalStorageService.setString(_keyTab, value.tab.name);
    await LocalStorageService.setBool(_keyUnisex, value.includeUnisex);
  }
}
