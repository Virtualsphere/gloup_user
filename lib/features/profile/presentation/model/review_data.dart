//review model
import 'dart:convert';

class ReviewData {
  String? profilePic;
  dynamic rating;
  String? reviewDescription;
  int? reviewId;
  String? cretaedAt;
  String? updatedAt;
  String? storeName;
  List<String>? storeImages;
  int? id;
  int? storeId;
  String? addressLine1;
  String? addressLine2;
  String? district;
  String? city;
  int? zipcode;
  dynamic landmark;
  String? latitude;
  String? longitude;
  String? status;

  ReviewData({
    this.profilePic,
    this.rating,
    this.reviewDescription,
    this.reviewId,
    this.cretaedAt,
    this.updatedAt,
    this.storeName,
    this.storeImages,
    this.id,
    this.storeId,
    this.addressLine1,
    this.addressLine2,
    this.district,
    this.city,
    this.zipcode,
    this.landmark,
    this.latitude,
    this.longitude,
    this.status,
  });

  ReviewData.fromJson(Map<String, dynamic> json) {
    profilePic = json['profilePic'];
    rating = json['rating'];
    reviewDescription = json['review_description'];
    reviewId = json['review_id'];
    cretaedAt = json['cretaed_at'];
    updatedAt = json['updated_at'];
    storeName = json['store_name'];
    if (json['store_images'] != null) {
      if (json['store_images'] is String) {
        // Parse JSON string to list
        try {
          final dynamic decoded = jsonDecode(json['store_images']);
          storeImages = decoded is List ? List<String>.from(decoded) : [];
        } catch (e) {
          storeImages = [];
        }
      } else if (json['store_images'] is List) {
        storeImages = List<String>.from(json['store_images']);
      }
    }
    id = json['id'];
    storeId = json['store_id'];
    addressLine1 = json['addressLine1'];
    addressLine2 = json['addressLine2'];
    district = json['district'];
    city = json['city'];
    zipcode = json['zipcode'];
    landmark = json['landmark'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    status = json['status'];
  }
}
