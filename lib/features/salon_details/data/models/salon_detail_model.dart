class SalonDetailModel {
  final String id;
  final String name;
  final bool isNew;
  final bool isPremium;
  final double rating;
  final int reviewCount;
  final String gender; // 'Unisex', 'Men', 'Women'
  final String address;
  final bool isOpen;
  final String openingTime;
  final String closingTime;
  final List<String> languages;
  final List<String> images;
  final String about;
  final List<ServiceModel> services;
  final List<AmbientModel> ambients;
  final List<TeamMemberModel> teamMembers;
  final List<ReviewModel> reviews;
  final Map<String, String> openingHours; // day: hours
  final LocationModel location;

  SalonDetailModel({
    required this.id,
    required this.name,
    this.isNew = false,
    this.isPremium = false,
    required this.rating,
    required this.reviewCount,
    required this.gender,
    required this.address,
    required this.isOpen,
    required this.openingTime,
    required this.closingTime,
    required this.languages,
    required this.images,
    required this.about,
    required this.services,
    required this.ambients,
    required this.teamMembers,
    required this.reviews,
    required this.openingHours,
    required this.location,
  });

  factory SalonDetailModel.fromJson(Map<String, dynamic> json) {
    return SalonDetailModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isNew: json['isNew'] ?? false,
      isPremium: json['isPremium'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      gender: json['gender'] ?? 'Unisex',
      address: json['address'] ?? '',
      isOpen: json['isOpen'] ?? false,
      openingTime: json['openingTime'] ?? '',
      closingTime: json['closingTime'] ?? '',
      languages: List<String>.from(json['languages'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      about: json['about'] ?? '',
      services: (json['services'] as List?)
              ?.map((e) => ServiceModel.fromJson(e))
              .toList() ??
          [],
      ambients: (json['ambients'] as List?)
              ?.map((e) => AmbientModel.fromJson(e))
              .toList() ??
          [],
      teamMembers: (json['teamMembers'] as List?)
              ?.map((e) => TeamMemberModel.fromJson(e))
              .toList() ??
          [],
      reviews: (json['reviews'] as List?)
              ?.map((e) => ReviewModel.fromJson(e))
              .toList() ??
          [],
      openingHours: Map<String, String>.from(json['openingHours'] ?? {}),
      location: LocationModel.fromJson(json['location'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isNew': isNew,
      'isPremium': isPremium,
      'rating': rating,
      'reviewCount': reviewCount,
      'gender': gender,
      'address': address,
      'isOpen': isOpen,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'languages': languages,
      'images': images,
      'about': about,
      'services': services.map((e) => e.toJson()).toList(),
      'ambients': ambients.map((e) => e.toJson()).toList(),
      'teamMembers': teamMembers.map((e) => e.toJson()).toList(),
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'openingHours': openingHours,
      'location': location.toJson(),
    };
  }
}

class ServiceModel {
  final String id;
  final String name;
  final String duration;
  final double price;
  final double? originalPrice;
  final String? discountPercentage;
  final bool isPopular;
  final String category;

  ServiceModel({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    this.originalPrice,
    this.discountPercentage,
    this.isPopular = false,
    required this.category,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      duration: json['duration'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      discountPercentage: json['discountPercentage'],
      isPopular: json['isPopular'] ?? false,
      category: json['category'] ?? 'Featured',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'price': price,
      'originalPrice': originalPrice,
      'discountPercentage': discountPercentage,
      'isPopular': isPopular,
      'category': category,
    };
  }
}

class AmbientModel {
  final String id;
  final String icon; // icon name or code
  final String label;

  AmbientModel({
    required this.id,
    required this.icon,
    required this.label,
  });

  factory AmbientModel.fromJson(Map<String, dynamic> json) {
    return AmbientModel(
      id: json['id'] ?? '',
      icon: json['icon'] ?? '',
      label: json['label'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'icon': icon,
      'label': label,
    };
  }
}

class TeamMemberModel {
  final String id;
  final String name;
  final String role;
  final String imageUrl;

  TeamMemberModel({
    required this.id,
    required this.name,
    required this.role,
    required this.imageUrl,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'imageUrl': imageUrl,
    };
  }
}

class ReviewModel {
  final String id;
  final String userName;
  final String? userImage;
  final String timeAgo;
  final double rating;
  final String reviewText;

  ReviewModel({
    required this.id,
    required this.userName,
    this.userImage,
    required this.timeAgo,
    required this.rating,
    required this.reviewText,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      userName: json['userName'] ?? '',
      userImage: json['userImage'],
      timeAgo: json['timeAgo'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewText: json['reviewText'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'userImage': userImage,
      'timeAgo': timeAgo,
      'rating': rating,
      'reviewText': reviewText,
    };
  }
}

class LocationModel {
  final double latitude;
  final double longitude;
  final String address;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}
