import 'package:equatable/equatable.dart';

enum HomeGenderTab { male, female }

/// Home gender controls (Figma 3-2): the Male / Female tabs plus the
/// "UNI SEX" switch.
///
/// With the switch on (default) unisex salons are included alongside the
/// selected gender; off shows that gender's salons only.
class HomeGender extends Equatable {
  final HomeGenderTab tab;
  final bool includeUnisex;

  const HomeGender({
    this.tab = HomeGenderTab.male,
    this.includeUnisex = true,
  });

  /// Value for the `gender` API parameter: male, female, male_only, female_only.
  String get apiValue => includeUnisex ? tab.name : '${tab.name}_only';

  HomeGender copyWith({HomeGenderTab? tab, bool? includeUnisex}) => HomeGender(
        tab: tab ?? this.tab,
        includeUnisex: includeUnisex ?? this.includeUnisex,
      );

  @override
  List<Object?> get props => [tab, includeUnisex];
}
