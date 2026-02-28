import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/enums.dart';
import 'package:tressy/core/constants/themes.dart';
import 'package:tressy/features/home/presentation/widgets/search_bar_widget.dart';
import 'package:tressy/features/widgets/custom_image.dart';
import 'package:tressy/features/widgets/custom_indicator.dart';
import 'package:tressy/features/widgets/custom_snackbar.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/salon_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool favotites = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Favorites',
          style: context.textTheme.displaySmall?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, top: 15.0),
              child: SearchBarWidget(
                onTap: () {},
                onSettingsTap: () {},
              ),
            ),
            Expanded(
              child: favotites
                  ? NoDataImageWidget()
                  : ListView.builder(
                      itemCount: 2,
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 20.0),
                      itemBuilder: (context, index) {
                        return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: SalonCard(
                              salonName: 'Royal Beauty',
                              salonImage: 'https://i.pravatar.cc/300',
                              images: [
                                'https://i.pravatar.cc/300',
                                'https://i.pravatar.cc/300'
                              ],
                              rating: 4.5,
                              reviewCount: 100,
                              distance: 3,
                              isPremium: true,
                              isFavorite: true,
                              serviceName: 'Royal Bueaty',
                              servicePrice: 100,
                              categories: ['test', 'value', 'amount'],
                              languageCodes: ['A'],
                              onTap: () {},
                            ));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class SalonData {
  final int storeId;
  final String name;
  final String district;
  final double averagerating;
  final double distanceM;
  final List<String> images;

  SalonData({
    required this.storeId,
    required this.name,
    required this.district,
    required this.averagerating,
    required this.distanceM,
    required this.images,
  });
}

class SalonContainerHorizontal extends StatefulWidget {
  const SalonContainerHorizontal({
    super.key,
    required this.salonData,
    required this.onTap,
    this.favouriteOnTap,
    this.itemIndex,
    this.isMaps,
    this.isFavouriteIcon = false,
    this.isFavourite = false,
  });

  final SalonData salonData;
  final int? itemIndex;
  final bool? isMaps;
  final VoidCallback? onTap, favouriteOnTap;
  final bool isFavouriteIcon, isFavourite;

  @override
  State<SalonContainerHorizontal> createState() =>
      _SalonContainerHorizontalState();
}

class _SalonContainerHorizontalState extends State<SalonContainerHorizontal> {
  int currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final List<String> imageUrl = widget.salonData.images;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: Themes.dropDownBoxDecoration(radius: 10),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //image part
            Container(
              height: widget.isMaps != true ? 185 : 165,
              width: MediaQuery.of(context).size.width * 0.95,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  //if no images
                  if (imageUrl.isEmpty)
                    NoDataImageWidget()
                  else
                    CarouselSlider(
                      carouselController: _carouselController,
                      options: CarouselOptions(
                        viewportFraction: 1,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 4),
                        enlargeCenterPage: true,
                        enableInfiniteScroll: true,
                        onPageChanged: (index, reason) {
                          setState(() {
                            currentIndex = index;
                          });
                        },
                      ),
                      items: imageUrl.map((image) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CustomNetworkImage(
                            imageUrl: image,
                            imageType: ImageType.images,
                          ),
                        );
                      }).toList(),
                    ),

                  //indicator
                  if (imageUrl.isNotEmpty)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: CustomIndicator(
                        activeColor: AppColors.white,
                        inActiveColor: AppColors.circleGreyColor,
                        currentIndex: currentIndex,
                        itemCount: imageUrl.length,
                        activeWidth: 17,
                        inactiveWidth: 12,
                        borderHeight: 2.5,
                      ),
                    ),

                  //favourite icon
                  if (widget.isFavouriteIcon)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: InkWell(
                        onTap: widget.favouriteOnTap,
                        child: Container(
                          height: 30,
                          width: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: widget.isFavourite
                                ? const Icon(
                                    Icons.favorite,
                                    color: AppColors.darkRed,
                                    size: 18,
                                  )
                                : const Icon(
                                    Icons.favorite_border,
                                    size: 18,
                                  ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // name + rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.salonData.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: AppColors.ratingYellowDark, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          widget.salonData.averagerating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12),
                        )
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                //location
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 14, color: AppColors.circleGreyColor),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        widget.salonData.district,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${((widget.salonData.distanceM) / 1000).toStringAsFixed(1)} km away',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
