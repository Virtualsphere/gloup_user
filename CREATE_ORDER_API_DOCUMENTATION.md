# Create Order API Documentation

## Overview
This document outlines the requirements for the **Create Order API** based on the booking confirmation flow in the application.

---

## API Endpoint
```
POST /api/orders
```

---

## Request Payload Structure

### 1. **Basic Order Information**
```json
{
  "user_id": "string (UUID)",
  "store_id": "string (UUID)",
  "booking_date": "string (ISO 8601 datetime)",
  "slot_id": "string (UUID)"
}
```

### 2. **Service Information**
```json
{
  "services": [
    {
      "service_id": "string (UUID)",
      "service_name": "string",
      "duration": "string (e.g., '30 min')",
      "price": "number (original price)",
      "discount_percentage": "string (e.g., '20%')",
      "category": "string"
    }
  ],
  "is_combo": "boolean"
}
```

### 3. **Guest/Booking For Information**
```json
{
  "booking_for": "string (enum: 'myself', 'someone_else')",
  "guest_id": "string (UUID, nullable - if booking for someone else)",
  "guest_name": "string (nullable)",
  "guest_phone": "string (nullable)",
  "guest_gender": "string (nullable)"
}
```

### 4. **Professional Information**
```json
{
  "professional_id": "string (UUID, nullable)"
}
```

### 5. **Payment Information**
```json
{
  "amount": "number (final total amount)",
  "payment_status": "string (enum: 'pending', 'success', 'failed')",
  "payment_id": "string (nullable - from payment gateway)",
  "razorpay_id": "string (nullable - Razorpay order ID)",
  "razorpay_signature": "string (nullable - for verification)",
  "is_wallet": "boolean (if Gloup Cash/wallet used)"
}
```

### 6. **Discount & Coupon Information**
```json
{
  "is_discounted": "boolean",
  "discounted_amount": "number (service discount amount)",
  "discount_id": "string (UUID, nullable - coupon ID if applied)",
  "coupon_code": "string (nullable)",
  "coupon_discount_amount": "number (coupon discount)"
}
```

### 7. **Additional Charges**
```json
{
  "gst": "number (GST amount - 5% of subtotal)",
  "platform_fee": "number (usually 0 - waived)",
  "wallet_amount_used": "number (Gloup Cash used)"
}
```

### 8. **Booking Status**
```json
{
  "status": "string (enum: 'pending', 'confirmed', 'completed', 'cancelled')"
}
```

---

## Complete Request Example

```json
{
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "store_id": "987e6543-e21b-98d7-c654-426614174999",
  "booking_date": "2026-03-15T14:30:00Z",
  "slot_id": 1,
  "services": [
    {
      "service_id": 2,
      "service_name": "Haircut",
      "duration": "30 min",
      "price": 500,
      "discount_percentage": "20%",
      "category": "Hair"
    },
    {
      "service_id": 3,
      "service_name": "Beard Trim",
      "duration": "15 min",
      "price": 200,
      "discount_percentage": "10%",
      "category": "Beard"
    }
  ],
  "is_combo": false,
  "booking_for": "myself",
  "guest_id": null,
  "professional_id": 3,
  "amount": 654,
  "payment_status": "pending",
  // "is_wallet": true,
  "is_discounted": true,
  "discounted_amount": 120,
  "discount_id": 3,
  "coupon_code": "GLOUP50",
  "coupon_discount_amount": 50,
  "gst": 30.6,
  "platform_fee": 0,
  "wallet_amount_used": 70,
  "status": "pending"
}
```

---

## Database Schema Recommendations

### Current Columns (Already Present)
- ✅ `id`
- ✅ `user_id`
- ✅ `store_id`
- ✅ `booking_date`
- ✅ `created_at`
- ✅ `updated_at`
- ✅ `amount`
- ✅ `slot_id`
- ✅ `is_combo`
- ✅ `professional_id` (note: typo in current DB - should be `professional_id`)
- ✅ `razorpay_id`
- ✅ `payment_status`
- ✅ `payment_id`
- ✅ `is_wallet`
- ✅ `is_discounted`
- ✅ `discounted_amount`
- ✅ `discount_id`
- ✅ `gst`
- ✅ `status`
- ✅ `razorpay_signature`

### **Recommended New Columns to Add**

#### 1. **Guest/Booking For Tracking**
```sql
ALTER TABLE orders ADD COLUMN booking_for VARCHAR(20) DEFAULT 'myself';
-- Values: 'myself', 'someone_else'

ALTER TABLE orders ADD COLUMN guest_id UUID NULL;
-- References the guest/person table if booking for someone else

ALTER TABLE orders ADD COLUMN guest_name VARCHAR(255) NULL;
-- Store guest name for quick reference

ALTER TABLE orders ADD COLUMN guest_phone VARCHAR(20) NULL;
-- Store guest phone for quick reference

ALTER TABLE orders ADD COLUMN guest_gender VARCHAR(10) NULL;
-- Store guest gender ('male', 'female', 'other')
```

#### 2. **Coupon Details**
```sql
ALTER TABLE orders ADD COLUMN coupon_code VARCHAR(50) NULL;
-- Store the actual coupon code used

ALTER TABLE orders ADD COLUMN coupon_discount_amount DECIMAL(10, 2) DEFAULT 0;
-- Store the discount amount from coupon separately
```

#### 3. **Additional Charges Breakdown**
```sql
ALTER TABLE orders ADD COLUMN platform_fee DECIMAL(10, 2) DEFAULT 0;
-- Platform fee (currently waived but good to track)

ALTER TABLE orders ADD COLUMN wallet_amount_used DECIMAL(10, 2) DEFAULT 0;
-- Amount deducted from Gloup Cash/wallet
```

#### 4. **Service Discount Tracking**
```sql
ALTER TABLE orders ADD COLUMN service_discount_amount DECIMAL(10, 2) DEFAULT 0;
-- Store the service-level discount amount (different from coupon discount)
```

#### 5. **Original Amount Tracking**
```sql
ALTER TABLE orders ADD COLUMN original_amount DECIMAL(10, 2) NULL;
-- Store the original total before any discounts
```

#### 6. **Time Slot Information**
```sql
ALTER TABLE orders ADD COLUMN selected_time_slot VARCHAR(50) NULL;
-- Store the time slot string (e.g., "02:00 PM - 02:30 PM")
```

---

## Separate Tables Required

### 1. **order_services Table** (Many-to-Many Relationship)
Since an order can have multiple services, create a separate table:

```sql
CREATE TABLE order_services (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  service_id UUID NOT NULL,
  service_name VARCHAR(255) NOT NULL,
  duration VARCHAR(50),
  price DECIMAL(10, 2) NOT NULL,
  discount_percentage VARCHAR(10),
  discounted_price DECIMAL(10, 2),
  category VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(order_id, service_id)
);

CREATE INDEX idx_order_services_order_id ON order_services(order_id);
CREATE INDEX idx_order_services_service_id ON order_services(service_id);
```

### 2. **guests Table** (If not already exists)
For storing "someone else" booking profiles:

```sql
CREATE TABLE guests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  gender VARCHAR(10),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_guests_user_id ON guests(user_id);
```

---

## Calculation Logic (From Frontend)

### 1. **Service Amount (Original)**
```
Sum of all service prices (before discount)
```

### 2. **Service Discount**
```
For each service:
  discount = price * (discount_percentage / 100)
Total Service Discount = Sum of all service discounts
```

### 3. **Subtotal After Service Discount**
```
subtotal = service_amount - service_discount
```

### 4. **Coupon Discount**
```
Applied only if:
  (subtotal + platform_fee) >= coupon_minimum_amount
coupon_discount = coupon discount amount (from coupon API)
```

### 5. **Subtotal After Coupon**
```
subtotal_after_coupon = subtotal - coupon_discount
```

### 6. **GST Calculation**
```
gst = (subtotal_after_coupon * 5) / 100
```

### 7. **Platform Fee**
```
platform_fee = 0 (currently waived)
```

### 8. **Total Before Wallet**
```
total_before_wallet = subtotal_after_coupon + gst + platform_fee
```

### 9. **Wallet/Gloup Cash**
```
wallet_amount = 70 (if checkbox is checked, else 0)
```

### 10. **Final Amount**
```
final_amount = total_before_wallet - wallet_amount
```

---

## API Response Structure

### Success Response (201 Created)
```json
{
  "success": true,
  "message": "Order created successfully",
  "data": {
    "order_id": 23,
    "razorpay_order_id": "order_MN1234567890",
    "amount": 654,
    "currency": "INR",
    "booking_date": "2026-03-15T14:30:00Z",
    "status": "pending"
  }
}
```

### Error Response (400 Bad Request)
```json
{
  "success": false,
  "message": "Invalid request",
  "errors": [
    {
      "field": "slot_id",
      "message": "Slot is already booked"
    }
  ]
}
```

---

## Validation Rules

1. **user_id**: Required, must exist in users table
2. **store_id**: Required, must exist in stores table
3. **booking_date**: Required, must be future date/time
4. **slot_id**: Required, must exist and be available
5. **services**: Required, must have at least 1 service
6. **amount**: Required, must be > 0
7. **professional_id**: Optional
8. **discount_id**: Optional, validate coupon if provided
9. **razorpay_id**: Required for payment processing
10. **booking_for**: If 'someone_else', guest details required

---

## Payment Flow Integration

### 1. **Create Order (Pending)**
- Status: `pending`
- payment_status: `pending`
- Generate `razorpay_order_id`

### 2. **Payment Success Callback**
- Update `payment_status`: `success`
- Add `payment_id` from Razorpay
- Add `razorpay_signature` for verification
- Update `status`: `confirmed`

### 3. **Payment Failure**
- Update `payment_status`: `failed`
- Keep `status`: `pending` or `cancelled`

---

## Additional Notes

1. **Timezone Handling**: Store all timestamps in UTC
2. **Currency**: Currently INR (Indian Rupee)
3. **GST Rate**: 5% (configurable)
4. **Wallet Balance**: Check user's available Gloup Cash before applying
5. **Slot Locking**: Implement optimistic/pessimistic locking to prevent double booking
6. **Transaction**: Use database transactions for order creation
7. **Audit Trail**: Log all order status changes

---

## Summary of Required Database Changes

### **New Columns for `orders` Table:**
1. `booking_for` - VARCHAR(20)
2. `guest_id` - UUID (nullable)
3. `guest_name` - VARCHAR(255) (nullable)
4. `guest_phone` - VARCHAR(20) (nullable)
5. `guest_gender` - VARCHAR(10) (nullable)
6. `coupon_code` - VARCHAR(50) (nullable)
7. `coupon_discount_amount` - DECIMAL(10, 2)
8. `platform_fee` - DECIMAL(10, 2)
9. `wallet_amount_used` - DECIMAL(10, 2)
10. `service_discount_amount` - DECIMAL(10, 2)
11. `original_amount` - DECIMAL(10, 2) (nullable)
12. `selected_time_slot` - VARCHAR(50) (nullable)

### **New Tables:**
1. **order_services** - For storing multiple services per order
2. **guests** - For storing "someone else" profiles (if not exists)

---

## Migration Script Example

```sql
-- Add new columns to orders table
ALTER TABLE orders 
  ADD COLUMN booking_for VARCHAR(20) DEFAULT 'myself',
  ADD COLUMN guest_id UUID NULL,
  ADD COLUMN guest_name VARCHAR(255) NULL,
  ADD COLUMN guest_phone VARCHAR(20) NULL,
  ADD COLUMN guest_gender VARCHAR(10) NULL,
  ADD COLUMN coupon_code VARCHAR(50) NULL,
  ADD COLUMN coupon_discount_amount DECIMAL(10, 2) DEFAULT 0,
  ADD COLUMN platform_fee DECIMAL(10, 2) DEFAULT 0,
  ADD COLUMN wallet_amount_used DECIMAL(10, 2) DEFAULT 0,
  ADD COLUMN service_discount_amount DECIMAL(10, 2) DEFAULT 0,
  ADD COLUMN original_amount DECIMAL(10, 2) NULL,
  ADD COLUMN selected_time_slot VARCHAR(50) NULL;

-- Create order_services table
CREATE TABLE order_services (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  service_id UUID NOT NULL,
  service_name VARCHAR(255) NOT NULL,
  duration VARCHAR(50),
  price DECIMAL(10, 2) NOT NULL,
  discount_percentage VARCHAR(10),
  discounted_price DECIMAL(10, 2),
  category VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(order_id, service_id)
);

CREATE INDEX idx_order_services_order_id ON order_services(order_id);
CREATE INDEX idx_order_services_service_id ON order_services(service_id);

-- Create guests table (if not exists)
CREATE TABLE IF NOT EXISTS guests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  gender VARCHAR(10),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_guests_user_id ON guests(user_id);
```

---

**Last Updated**: March 3, 2026
