# 📱 Tressy Saloon App - API Documentation

## Overview
This document provides complete API specifications for implementing the Banner and Category endpoints for the Tressy Saloon mobile application.

---

## 🌐 Base Configuration

### Base URLs
```
API Base URL: http://192.168.1.2:5678
Image Base URL: https://v1.gloup.in/images
Profile Image URL: https://v1.gloup.in/profilepic
```

### Common Response Format
All endpoints follow a standardized response format:

```json
{
  "success": true,
  "message": "Success message here",
  "data": [...]
}
```

### Error Response Format
```json
{
  "success": false,
  "message": "Error description here",
  "data": null
}
```

---

## 📋 API Endpoints

---

## 1️⃣ Get Banners API

### Endpoint Details
- **Method:** `GET`
- **URL:** `/user/app/v2/getbanner`
- **Full URL:** `http://192.168.1.2:5678/user/app/v2/getbanner`
- **Authentication:** Optional (depends on your implementation)
- **Content-Type:** `application/json`

### Request

#### Headers (if authentication required)
```http
Authorization: Bearer <access_token>
Content-Type: application/json
```

#### Query Parameters
None required. Optional parameters can be added:
- `status` (optional): Filter by active/inactive banners
- `limit` (optional): Number of banners to return

#### Sample Request
```bash
curl -X GET "http://192.168.1.2:5678/user/app/v2/getbanner" \
  -H "Content-Type: application/json"
```

### Response

#### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Banners fetched successfully",
  "data": [
    {
      "id": 1,
      "image": "1755662688825-banner1.png"
    },
    {
      "id": 2,
      "image": "1754914972543-banner2.png"
    },
    {
      "id": 3,
      "image": "1758104282369-banner3.png"
    }
  ]
}
```

#### Response Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `success` | boolean | Yes | Indicates if the request was successful |
| `message` | string | Yes | Human-readable message |
| `data` | array | Yes | Array of banner objects |
| `data[].id` | integer/string | Yes | Unique identifier for the banner |
| `data[].image` | string | Yes | Image filename (will be appended to imageProfileUrl) |

#### Image URL Construction
The app will automatically construct the full image URL:
```
Full URL = https://v1.gloup.in/profilepic/{image}

Example:
Input:  "1755662688825-banner1.png"
Output: "https://v1.gloup.in/profilepic/1755662688825-banner1.png"
```

#### Error Responses

**400 Bad Request**
```json
{
  "success": false,
  "message": "Invalid request parameters",
  "data": null
}
```

**401 Unauthorized** (if authentication required)
```json
{
  "success": false,
  "message": "Unauthorized access",
  "data": null
}
```

**500 Internal Server Error**
```json
{
  "success": false,
  "message": "Internal server error occurred",
  "data": null
}
```

### Implementation Notes
1. **Image Storage:** Store only the filename in the database
2. **Image Format:** Support PNG, JPG, JPEG formats
3. **Image Size:** Recommended banner size: 1200x400 pixels (3:1 ratio)
4. **Ordering:** Banners should be returned in display order (use an `order` or `priority` field)
5. **Caching:** Consider implementing cache headers for better performance

### Database Schema Example
```sql
CREATE TABLE banners (
  id INT PRIMARY KEY AUTO_INCREMENT,
  image VARCHAR(255) NOT NULL,
  title VARCHAR(255),
  description TEXT,
  link_url VARCHAR(500),
  order_index INT DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

---

## 2️⃣ Get Categories API

### Endpoint Details
- **Method:** `GET`
- **URL:** `/user/app/v2/getallcategory`
- **Full URL:** `http://192.168.1.2:5678/user/app/v2/getallcategory`
- **Authentication:** Optional (depends on your implementation)
- **Content-Type:** `application/json`

### Request

#### Headers (if authentication required)
```http
Authorization: Bearer <access_token>
Content-Type: application/json
```

#### Query Parameters
Optional parameters:
- `status` (optional): Filter by active/inactive categories
- `limit` (optional): Number of categories to return
- `offset` (optional): Pagination offset

#### Sample Request
```bash
curl -X GET "http://192.168.1.2:5678/user/app/v2/getallcategory" \
  -H "Content-Type: application/json"
```

### Response

#### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Categories fetched successfully",
  "data": [
    {
      "id": 4,
      "label": "Grooming",
      "imageUrl": "1755662688825-im.png"
    },
    {
      "id": 3,
      "label": "Hair cut",
      "imageUrl": "1754914972543-Salon 2.png"
    },
    {
      "id": 2,
      "label": "Beauty Parlour",
      "imageUrl": "1758104282369-1754914948867-Parlor 2.png"
    },
    {
      "id": 1,
      "label": "Massage",
      "imageUrl": "1754914927956-Massage 2.png"
    }
  ]
}
```

#### Response Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `success` | boolean | Yes | Indicates if the request was successful |
| `message` | string | Yes | Human-readable message |
| `data` | array | Yes | Array of category objects |
| `data[].id` | integer/string | Yes | Unique identifier for the category |
| `data[].label` | string | Yes | Category name (may contain trailing spaces - will be trimmed by app) |
| `data[].imageUrl` | string | Yes | Image filename (will be appended to imageBaseUrl) |

#### Image URL Construction
The app will automatically construct the full image URL:
```
Full URL = https://v1.gloup.in/images/{imageUrl}

Example:
Input:  "1755662688825-im.png"
Output: "https://v1.gloup.in/images/1755662688825-im.png"
```

#### Error Responses

**400 Bad Request**
```json
{
  "success": false,
  "message": "Invalid request parameters",
  "data": null
}
```

**401 Unauthorized** (if authentication required)
```json
{
  "success": false,
  "message": "Unauthorized access",
  "data": null
}
```

**404 Not Found**
```json
{
  "success": false,
  "message": "No categories found",
  "data": null
}
```

**500 Internal Server Error**
```json
{
  "success": false,
  "message": "Internal server error occurred",
  "data": null
}
```

### Implementation Notes
1. **Label Trimming:** The app automatically trims whitespace from labels (e.g., "Grooming " → "Grooming")
2. **ID Type:** Support both integer and string IDs - app converts to string automatically
3. **Image Format:** Support PNG, JPG, JPEG formats
4. **Image Size:** Recommended category icon size: 200x200 pixels (1:1 ratio)
5. **Ordering:** Categories can be returned in any order (app can sort if needed)
6. **Caching:** Implement cache headers as categories don't change frequently

### Database Schema Example
```sql
CREATE TABLE categories (
  id INT PRIMARY KEY AUTO_INCREMENT,
  label VARCHAR(100) NOT NULL,
  imageUrl VARCHAR(255) NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  order_index INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

---

## 🔐 Error Handling

### HTTP Status Codes
The API should use standard HTTP status codes:

| Code | Meaning | When to Use |
|------|---------|-------------|
| 200 | OK | Request successful |
| 400 | Bad Request | Invalid parameters or request format |
| 401 | Unauthorized | Authentication required or failed |
| 403 | Forbidden | User doesn't have permission |
| 404 | Not Found | Resource doesn't exist |
| 500 | Internal Server Error | Server-side error occurred |
| 503 | Service Unavailable | Server is down or maintenance |

### Error Response Structure
Always include these fields in error responses:
```json
{
  "success": false,
  "message": "Detailed error message for developers",
  "data": null,
  "error_code": "OPTIONAL_ERROR_CODE" // Optional, for specific error tracking
}
```

---

## 📊 Client-Side Implementation

### How the App Processes Responses

#### Banner API Response Processing
```dart
1. Fetch data from: GET /user/app/v2/getbanner
2. Parse JSON response
3. For each banner:
   - Convert ID to string: json['id']?.toString()
   - Construct full URL: imageProfileUrl + '/' + json['image']
4. Display in carousel
```

#### Category API Response Processing
```dart
1. Fetch data from: GET /user/app/v2/getallcategory
2. Parse JSON response
3. For each category:
   - Convert ID to string: json['id']?.toString()
   - Trim label: json['label']?.trim()
   - Construct full URL: imageBaseUrl + '/' + json['imageUrl']
4. Cache in CategoryBloc (singleton)
5. Display across multiple screens
```

---

## 🧪 Testing

### Test Cases for Banners API

#### Test 1: Successful Request
```bash
curl -X GET "http://192.168.1.2:5678/user/app/v2/getbanner"
```
Expected: 200 OK with array of banners

#### Test 2: Empty Result
```bash
# When no banners exist
```
Expected: 200 OK with empty array `{"success": true, "data": []}`

#### Test 3: Server Error
```bash
# When database is down
```
Expected: 500 with error message

### Test Cases for Categories API

#### Test 1: Successful Request
```bash
curl -X GET "http://192.168.1.2:5678/user/app/v2/getallcategory"
```
Expected: 200 OK with array of categories

#### Test 2: Integer and String IDs
Test that API can return both:
```json
{"id": 1}      // Integer - will be converted to "1"
{"id": "cat_1"} // String - will remain "cat_1"
```

#### Test 3: Labels with Whitespace
Test that labels with trailing spaces are handled:
```json
{"label": "Grooming "} // Will be trimmed to "Grooming"
```

---

## 📱 Sample Mobile App Code

### Fetching Banners
```dart
// This is already implemented in your app
final response = await dioClient.get('/user/app/v2/getbanner');
final banners = (response.data['data'] as List)
    .map((json) => CarouselBannerModel.fromJson(
          json,
          imageBaseUrl: 'https://v1.gloup.in/profilepic',
        ))
    .toList();
```

### Fetching Categories
```dart
// This is already implemented in your app
final response = await dioClient.get('/user/app/v2/getallcategory');
final categories = (response.data['data'] as List)
    .map((json) => CategoryModel.fromJson(
          json,
          imageBaseUrl: 'https://v1.gloup.in/images',
        ))
    .toList();
```

---

## 🚀 Performance Recommendations

### Server-Side Optimizations
1. **Enable GZIP Compression** for JSON responses
2. **Add Cache-Control Headers:**
   ```http
   Cache-Control: public, max-age=3600
   ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
   ```
3. **Implement CDN** for images
4. **Database Indexing** on `id`, `is_active`, `order_index` fields
5. **Response Pagination** if categories exceed 50+ items

### Client-Side Optimizations (Already Implemented)
1. ✅ **Singleton CategoryBloc** - Prevents duplicate API calls
2. ✅ **State Caching** - Categories loaded once, reused across screens
3. ✅ **Image URL Construction** - Full URLs built client-side
4. ✅ **Type Safety** - Handles both int and string IDs
5. ✅ **Error Handling** - Comprehensive exception handling

---

## 📝 Implementation Checklist

### Backend Tasks
- [ ] Set up GET `/user/app/v2/getbanner` endpoint
- [ ] Set up GET `/user/app/v2/getallcategory` endpoint
- [ ] Implement error handling for both endpoints
- [ ] Add database tables for banners and categories
- [ ] Upload test images to image server
- [ ] Add cache headers for better performance
- [ ] Test with sample data
- [ ] Document any additional fields or parameters
- [ ] Set up CORS if needed for web app
- [ ] Implement logging for debugging

### Testing Tasks
- [ ] Test with empty database (no data)
- [ ] Test with integer IDs
- [ ] Test with string IDs
- [ ] Test with labels containing whitespace
- [ ] Test with invalid image filenames
- [ ] Test error responses (400, 401, 500)
- [ ] Test concurrent requests
- [ ] Test with large datasets (50+ items)
- [ ] Verify image URLs are accessible
- [ ] Test CORS for web clients

---

## 🔗 Additional Resources

### Image Upload Guidelines
- **Banners:** 1200x400px, PNG/JPG, max 500KB
- **Categories:** 200x200px, PNG/JPG, max 200KB
- **Naming:** Use timestamp prefix (e.g., `1755662688825-banner.png`)
- **Storage:** Store in `https://v1.gloup.in/images/` or `/profilepic/`

### API Versioning
Current version: `v2`
- All endpoints use `/user/app/v2/` prefix
- Maintain backward compatibility
- Document version changes

---

## 💡 FAQ

### Q: Can I change the field names?
**A:** The mobile app expects specific field names. If you need to change them, update the model classes:
- Banners: `id`, `image`
- Categories: `id`, `label`, `imageUrl`

### Q: What if I want to add more fields?
**A:** You can add additional optional fields to the response. The app will ignore unknown fields. Example:
```json
{
  "id": 1,
  "label": "Grooming",
  "imageUrl": "image.png",
  "description": "Full body grooming",  // Additional field
  "icon": "grooming_icon.svg"            // Additional field
}
```

### Q: Should images be stored in database?
**A:** Store only the filename/path in the database. Actual images should be stored in a file system or CDN.

### Q: How do I handle image uploads?
**A:** Create a separate image upload endpoint that returns the filename, then store that filename in the banners/categories table.

### Q: Can I return data in a different order?
**A:** Yes, but consider adding an `order_index` field to control display order in the app.

---

## 📞 Support

For questions or issues:
- Review the mobile app code in `lib/features/category/` and `lib/features/home/`
- Check the API routes in `lib/core/constants/api_routes.dart`
- Test endpoints using the provided curl commands
- Verify image URLs are accessible

---

**Last Updated:** February 2026  
**API Version:** v2  
**Mobile App:** Tressy Saloon Flutter App
