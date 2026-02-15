import 'package:tressy/features/salon_details/data/models/salon_detail_model.dart';

class SalonMockData {
  static SalonDetailModel getSalonDetails() {
    return SalonDetailModel(
      id: 'salon_001',
      name: 'Luxury Hair & Spa Studio',
      isNew: true,
      isPremium: true,
      rating: 4.5,
      reviewCount: 201,
      gender: 'Unisex',
      address: '123 Main Street, Downtown Area, City Center, State 12345',
      isOpen: true,
      openingTime: '06:30 AM',
      closingTime: '9:30 PM',
      languages: ['Tamil', 'English', 'Hindi'],
      images: [
        'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=800',
        'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=800',
        'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=800',
        'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=800',
      ],
      about:
          'We offer premium salon and spa services exclusively for men. Our experienced team provides top-quality haircuts, grooming, facials, and relaxation treatments in a modern, comfortable environment. Walk-ins welcome.',
      services: _getMockServices(),
      ambients: _getMockAmbients(),
      teamMembers: _getMockTeamMembers(),
      reviews: _getMockReviews(),
      openingHours: {
        'Monday': '6:00 AM - 9:00 PM',
        'Tuesday': '6:00 AM - 9:00 PM',
        'Wednesday': '6:00 AM - 9:00 PM',
        'Thursday': '6:00 AM - 9:00 PM',
        'Friday': '6:00 AM - 9:00 PM',
        'Saturday': '6:00 AM - 9:00 PM',
        'Sunday': '6:00 AM - 9:00 PM',
      },
      location: LocationModel(
        latitude: 13.0827,
        longitude: 80.2707,
        address: '123 Main Street, Downtown Area, City Center, State 12345',
      ),
    );
  }

  static List<ServiceModel> _getMockServices() {
    return [
      // Featured Category
      ServiceModel(
        id: 'service_001',
        name: "Men's Haircut",
        duration: '30 min',
        price: 299,
        isPopular: true,
        category: 'Featured',
      ),
      ServiceModel(
        id: 'service_002',
        name: "Hair Styling & Spa Treatment",
        duration: '45 min',
        price: 599,
        originalPrice: 799,
        discountPercentage: '25%',
        category: 'Featured',
      ),
      ServiceModel(
        id: 'service_003',
        name: "Beard Trim & Styling",
        duration: '20 min',
        price: 149,
        category: 'Featured',
      ),
      ServiceModel(
        id: 'service_004',
        name: "Premium Hair Color",
        duration: '90 min',
        price: 1499,
        originalPrice: 1999,
        discountPercentage: '25%',
        isPopular: true,
        category: 'Featured',
      ),
      ServiceModel(
        id: 'service_005',
        name: "Hair Spa & Deep Conditioning",
        duration: '60 min',
        price: 899,
        category: 'Featured',
      ),
      // Combo Offers
      ServiceModel(
        id: 'service_006',
        name: "Haircut + Beard Combo",
        duration: '45 min',
        price: 399,
        originalPrice: 448,
        discountPercentage: '10%',
        isPopular: true,
        category: 'Combo Offers',
      ),
      ServiceModel(
        id: 'service_007',
        name: "Full Grooming Package",
        duration: '120 min',
        price: 1299,
        originalPrice: 1698,
        discountPercentage: '23%',
        isPopular: true,
        category: 'Combo Offers',
      ),
      // Men's Package
      ServiceModel(
        id: 'service_008',
        name: "Classic Haircut",
        duration: '30 min',
        price: 249,
        category: "Men's Package",
      ),
      ServiceModel(
        id: 'service_009',
        name: "Beard Styling",
        duration: '25 min',
        price: 199,
        category: "Men's Package",
      ),
      ServiceModel(
        id: 'service_010',
        name: "Head Massage",
        duration: '30 min',
        price: 299,
        category: "Men's Package",
      ),
      // Women's Package
      ServiceModel(
        id: 'service_011',
        name: "Women's Haircut",
        duration: '45 min',
        price: 499,
        category: "Women's Package",
      ),
      ServiceModel(
        id: 'service_012',
        name: "Hair Coloring",
        duration: '120 min',
        price: 1999,
        category: "Women's Package",
      ),
      ServiceModel(
        id: 'service_013',
        name: "Blow Dry & Styling",
        duration: '40 min',
        price: 599,
        category: "Women's Package",
      ),
      // Hair Styling
      ServiceModel(
        id: 'service_014',
        name: "Hair Straightening",
        duration: '90 min',
        price: 1499,
        category: 'Hair Styling',
      ),
      ServiceModel(
        id: 'service_015',
        name: "Hair Curling",
        duration: '60 min',
        price: 999,
        category: 'Hair Styling',
      ),
      // Spa & Massage
      ServiceModel(
        id: 'service_016',
        name: "Full Body Massage",
        duration: '90 min',
        price: 1999,
        originalPrice: 2499,
        discountPercentage: '20%',
        category: 'Spa & Massage',
      ),
      ServiceModel(
        id: 'service_017',
        name: "Head & Shoulder Massage",
        duration: '45 min',
        price: 699,
        category: 'Spa & Massage',
      ),
      // Facial
      ServiceModel(
        id: 'service_018',
        name: "Gold Facial",
        duration: '60 min',
        price: 1299,
        isPopular: true,
        category: 'Facial',
      ),
      ServiceModel(
        id: 'service_019',
        name: "Deep Cleansing Facial",
        duration: '45 min',
        price: 899,
        category: 'Facial',
      ),
      // Makeup
      ServiceModel(
        id: 'service_020',
        name: "Bridal Makeup",
        duration: '180 min',
        price: 4999,
        category: 'Makeup',
      ),
      ServiceModel(
        id: 'service_021',
        name: "Party Makeup",
        duration: '90 min',
        price: 1999,
        category: 'Makeup',
      ),
    ];
  }

  static List<AmbientModel> _getMockAmbients() {
    return [
      AmbientModel(
        id: 'ambient_001',
        icon: 'wifi',
        label: 'Free WiFi',
      ),
      AmbientModel(
        id: 'ambient_002',
        icon: 'ac_unit',
        label: 'Air Conditioned',
      ),
      AmbientModel(
        id: 'ambient_003',
        icon: 'local_parking',
        label: 'Parking Available',
      ),
      AmbientModel(
        id: 'ambient_004',
        icon: 'credit_card',
        label: 'Card Payment',
      ),
      AmbientModel(
        id: 'ambient_005',
        icon: 'wheelchair_pickup',
        label: 'Wheelchair Accessible',
      ),
      AmbientModel(
        id: 'ambient_006',
        icon: 'coffee',
        label: 'Complimentary Beverages',
      ),
    ];
  }

  static List<TeamMemberModel> _getMockTeamMembers() {
    return [
      TeamMemberModel(
        id: 'member_001',
        name: 'John Doe',
        role: 'Senior Stylist',
        imageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      ),
      TeamMemberModel(
        id: 'member_002',
        name: 'Mike Smith',
        role: 'Hair Specialist',
        imageUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
      ),
      TeamMemberModel(
        id: 'member_003',
        name: 'David Brown',
        role: 'Barber',
        imageUrl:
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200',
      ),
      TeamMemberModel(
        id: 'member_004',
        name: 'Robert Wilson',
        role: 'Spa Therapist',
        imageUrl:
            'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=200',
      ),
    ];
  }

  static List<ReviewModel> _getMockReviews() {
    return [
      ReviewModel(
        id: 'review_001',
        userName: 'John Doe',
        timeAgo: '2 days ago',
        rating: 5.0,
        reviewText:
            'Excellent service! The staff was very professional and friendly. My haircut turned out perfect. Highly recommend this salon!',
      ),
      ReviewModel(
        id: 'review_002',
        userName: 'Sarah Miller',
        userImage:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
        timeAgo: '5 days ago',
        rating: 4.5,
        reviewText:
            'Great experience overall. The ambiance is nice and the service was good. Will definitely come back!',
      ),
      ReviewModel(
        id: 'review_003',
        userName: 'Mike Johnson',
        timeAgo: '1 week ago',
        rating: 5.0,
        reviewText:
            'Best salon in town! The stylist really understood what I wanted. Very happy with the result.',
      ),
      ReviewModel(
        id: 'review_004',
        userName: 'Emily Davis',
        userImage:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
        timeAgo: '2 weeks ago',
        rating: 4.0,
        reviewText:
            'Good service and reasonable prices. The place is clean and well-maintained.',
      ),
      ReviewModel(
        id: 'review_005',
        userName: 'Robert Brown',
        timeAgo: '3 weeks ago',
        rating: 5.0,
        reviewText:
            'Amazing experience! The team is skilled and attentive. Highly recommended!',
      ),
    ];
  }

  // Helper method to get star counts for review summary
  static Map<int, int> getStarCounts() {
    return {
      5: 120,
      4: 50,
      3: 20,
      2: 8,
      1: 3,
    };
  }

  // Helper method to get services by category
  static List<ServiceModel> getServicesByCategory(String category) {
    return _getMockServices()
        .where((service) => service.category == category)
        .toList();
  }

  // Helper method to get all service categories
  static List<String> getServiceCategories() {
    return [
      'Featured',
      'Combo Offers',
      "Men's Package",
      "Women's Package",
      'Hair Styling',
      'Spa & Massage',
      'Facial',
      'Makeup',
    ];
  }
}
