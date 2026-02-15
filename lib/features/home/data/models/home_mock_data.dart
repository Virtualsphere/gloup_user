import 'package:tressy/features/home/data/models/home_models.dart';

/// Mock data for Home Page APIs
class HomeMockData {
  // ========== CAROUSEL API ==========
  /// GET /api/v1/home/carousel
  static List<CarouselBannerModel> getCarouselBanners() {
    return [
        CarouselBannerModel(
          id: 'banner_001',
          imageUrl: 'https://media2.giphy.com/media/v1.Y2lkPTc5MGI3NjExeTF4ZGU1M25uampzemN4N3RnOGJlNjR1NjFlZXN6OTZqMWJpZnRlbCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/35ELYo9Ng4PxpzWhwH/giphy.gif',
        ),
        CarouselBannerModel(
          id: 'banner_002',
          imageUrl: 'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=800',
        ),
        CarouselBannerModel(
          id: 'banner_003',
          imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=800',
        ),
        CarouselBannerModel(
          id: 'banner_004',
          imageUrl: 'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=800',
        ),
        CarouselBannerModel(
          id: 'banner_005',
          imageUrl: 'https://images.unsplash.com/photo-1633681926022-84c23e8cb2d6?w=800',
        ),
      ];
  }

  // ========== CATEGORIES API ==========
  /// GET /api/v1/home/categories
  static List<CategoryModel> getCategories() {
    return [
        CategoryModel(
          id: 'cat_002',
          label: 'Haircut',
        ),
        CategoryModel(
          id: 'cat_003',
          label: 'Spa',
        ),
        CategoryModel(
          id: 'cat_004',
          label: 'Massage',
        ),
        CategoryModel(
          id: 'cat_005',
          label: 'Facial',
        ),
        CategoryModel(
          id: 'cat_006',
          label: 'Nail Art',
        ),
        CategoryModel(
          id: 'cat_007',
          label: 'Makeup',
        ),
        CategoryModel(
          id: 'cat_008',
          label: 'Waxing',
        ),
      ];
  }

  // ========== POPULAR SERVICES API ==========
  /// GET /api/v1/home/popular-services?lat=13.0827&lng=80.2707&radius=5
  static List<SalonModel> getPopularServices() {
    return  [
        SalonModel(
          id: 'salon_001',
          salonName: 'Luxury Hair & Spa Studio',
          salonImage: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=200',
          images: [
            'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
            'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400',
            'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400',
            'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=400',
          ],
          rating: 4.5,
          reviewCount: 201,
          distance: 1.2,
          isPremium: true,
          isFavorite: false,
          serviceName: 'Haircut',
          servicePrice: 299,
          categories: ['Haircut', 'Spa', 'Massage', 'Facial'],
          languageCodes: ['ta', 'en', 'hi'],
        ),
        SalonModel(
          id: 'salon_002',
          salonName: 'Glamour Beauty Lounge',
          salonImage: 'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=200',
          images: [
            'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400',
            'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
            'https://images.unsplash.com/photo-1633681926022-84c23e8cb2d6?w=400',
          ],
          rating: 4.8,
          reviewCount: 156,
          distance: 2.5,
          isPremium: false,
          isFavorite: true,
          serviceName: 'Facial',
          servicePrice: 899,
          categories: ['Facial', 'Makeup'],
          languageCodes: ['hi', 'en'],
        ),
        SalonModel(
          id: 'salon_003',
          salonName: 'Elite Gentleman\'s Barber Shop',
          salonImage: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=200',
          images: [
            'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
            'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400',
          ],
          rating: 4.7,
          reviewCount: 89,
          distance: 0.8,
          isPremium: true,
          isFavorite: false,
          serviceName: 'Trim & Shave',
          servicePrice: 199,
          categories: ['Haircut', 'Trim', 'Shave'],
          languageCodes: ['ml', 'en', 'ta'],
        ),
        SalonModel(
          id: 'salon_004',
          salonName: 'Serenity Spa & Wellness',
          salonImage: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=200',
          images: [
            'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=400',
            'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=400',
          ],
          rating: 4.9,
          reviewCount: 312,
          distance: 3.1,
          isPremium: false,
          isFavorite: false,
          serviceName: 'Thai Massage',
          servicePrice: 1299,
          categories: ['Spa', 'Massage'],
          languageCodes: ['te', 'hi', 'en'],
        ),
      ];
  }

  // ========== TOP SALONS API ==========
  /// GET /api/v1/home/top-salons?lat=13.0827&lng=80.2707&radius=10
  static List<SalonModel> getTopSalons() {
    return [
        SalonModel(
          id: 'salon_005',
          salonName: 'Royal Beauty Parlour',
          salonImage: 'https://images.unsplash.com/photo-1633681926022-84c23e8cb2d6?w=200',
          images: [
            'https://images.unsplash.com/photo-1633681926022-84c23e8cb2d6?w=400',
            'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
            'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400',
          ],
          rating: 4.9,
          reviewCount: 458,
          distance: 2.3,
          isPremium: true,
          isFavorite: false,
          serviceName: 'Bridal Makeup',
          servicePrice: 4999,
          categories: ['Makeup', 'Bridal', 'Facial', 'Spa'],
          languageCodes: ['kn', 'en', 'hi', 'ta'],
        ),
        SalonModel(
          id: 'salon_006',
          salonName: 'Modern Hair Studio',
          salonImage: 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=200',
          images: [
            'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400',
            'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
          ],
          rating: 4.8,
          reviewCount: 324,
          distance: 1.5,
          isPremium: false,
          isFavorite: false,
          serviceName: 'Hair Color',
          servicePrice: 1499,
          categories: ['Haircut', 'Color'],
          languageCodes: ['bn', 'en', 'hi'],
        ),
        SalonModel(
          id: 'salon_007',
          salonName: 'Bliss Spa & Wellness Center',
          salonImage: 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=200',
          images: [
            'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=400',
            'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=400',
            'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=400',
          ],
          rating: 4.9,
          reviewCount: 567,
          distance: 3.8,
          isPremium: true,
          isFavorite: true,
          serviceName: 'Full Body Massage',
          servicePrice: 1999,
          categories: ['Spa', 'Massage', 'Therapy'],
          languageCodes: ['gu', 'hi', 'en'],
        ),
        SalonModel(
          id: 'salon_008',
          salonName: 'Gentlemen\'s Club Barbershop',
          salonImage: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=200',
          images: [
            'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
            'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400',
          ],
          rating: 4.7,
          reviewCount: 198,
          distance: 1.9,
          isPremium: false,
          isFavorite: false,
          serviceName: 'Beard Styling',
          servicePrice: 199,
          categories: ['Haircut', 'Beard', 'Shave'],
          languageCodes: ['hi', 'en'],
        ),
      ];
  }

  // ========== RECOMMENDED SALONS API ==========
  /// GET /api/v1/home/recommended?userId=user_123
  static List<SalonModel> getRecommendedSalons() {
    return  [
        SalonModel(
          id: 'salon_009',
          salonName: 'Naturals Unisex Salon & Spa',
          salonImage: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=200',
          images: [
            'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
            'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400',
            'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400',
            'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=400',
          ],
          rating: 4.6,
          reviewCount: 892,
          distance: 1.8,
          isPremium: true,
          isFavorite: false,
          serviceName: 'Hair Spa',
          servicePrice: 799,
          categories: ['Haircut', 'Spa', 'Facial', 'Massage'],
          languageCodes: ['hi', 'en', 'ta'],
        ),
        SalonModel(
          id: 'salon_010',
          salonName: 'Lakme Salon',
          salonImage: 'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=200',
          images: [
            'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400',
            'https://images.unsplash.com/photo-1633681926022-84c23e8cb2d6?w=400',
            'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400',
          ],
          rating: 4.5,
          reviewCount: 1234,
          distance: 2.1,
          isPremium: false,
          isFavorite: true,
          serviceName: 'Manicure & Pedicure',
          servicePrice: 599,
          categories: ['Nail Art', 'Pedicure'],
          languageCodes: ['hi', 'en', 'bn'],
        ),
        SalonModel(
          id: 'salon_011',
          salonName: 'Groom & Style Men\'s Salon',
          salonImage: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=200',
          images: [
            'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
            'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400',
          ],
          rating: 4.7,
          reviewCount: 456,
          distance: 0.9,
          isPremium: true,
          isFavorite: false,
          serviceName: 'Royal Shave',
          servicePrice: 199,
          categories: ['Haircut', 'Shave', 'Trim'],
          languageCodes: ['hi', 'en'],
        ),
        SalonModel(
          id: 'salon_012',
          salonName: 'Aroma Thai Spa',
          salonImage: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=200',
          images: [
            'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=400',
            'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=400',
            'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=400',
          ],
          rating: 4.8,
          reviewCount: 678,
          distance: 3.2,
          isPremium: false,
          isFavorite: false,
          serviceName: 'Aromatherapy Massage',
          servicePrice: 1499,
          categories: ['Spa', 'Massage', 'Therapy', 'Wellness'],
          languageCodes: ['en', 'ta', 'ml'],
        ),
        SalonModel(
          id: 'salon_013',
          salonName: 'Enrich Salon & Academy',
          salonImage: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=200',
          images: [
            'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
            'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=400',
          ],
          rating: 4.6,
          reviewCount: 543,
          distance: 2.7,
          isPremium: true,
          isFavorite: false,
          serviceName: 'Keratin Treatment',
          servicePrice: 2999,
          categories: ['Hair Treatment', 'Smoothing'],
          languageCodes: ['kn', 'te', 'en', 'hi'],
        ),
      ];
  }

  // ========== HELPER METHODS ==========
  
  /// Simulate API delay
  static Future<T> simulateApiCall<T>(T data, {int delaySeconds = 2}) async {
    await Future.delayed(Duration(seconds: delaySeconds));
    return data;
  }
}
