import 'package:tressy/features/auth/domain/entities/auth_entity.dart';
import 'package:tressy/features/booking_confirmation/data/models/order_model.dart';
import 'package:tressy/features/booking_confirmation/domain/entities/order_entity.dart';
import 'package:tressy/features/profile/domain/entities/profile_entity.dart';

const sendOtpSuccess = SendOtpEntity(status: 200, message: 'OTP sent');

const verifyOtpSuccess = VerifyOtpEntity(
  status: 200,
  message: 'Verified',
  token: 'jwt-token',
);

const testProfile = ProfileEntity(
  id: 1,
  firstname: 'Jane',
  lastname: 'Doe',
  phone: 9876543210,
  age: 28,
  email: 'jane@example.com',
  dateOfBirth: '1996-01-01',
  city: 'Chennai',
  invitedCode: 'INV123',
  wallet: '0',
  profilePic: '',
  fullProfilePicUrl: '',
  gender: 'Female',
  country: 'India',
  status: 'active',
);

const testOrder = OrderEntity(
  orderId: 42,
  razorpayOrderId: 'order_test',
  amount: 499,
  currency: 'INR',
  bookingDate: '2025-06-23',
  status: 'pending',
);

const testDeleteProfileSuccess = DeleteProfileEntity(
  success: true,
  message: 'Profile deleted successfully',
);

const testDeleteProfileFailure = DeleteProfileEntity(
  success: false,
  message: 'Failed to delete profile',
);

const testCreateOrderRequest = CreateOrderRequest(
  bookingDate: '2025-06-23',
  slotId: 10,
  services: [
    {'service_id': 1, 'price': 499},
  ],
  isCombo: false,
  bookingFor: 'myself',
  storeId: 5,
  gst: 0,
  platformFee: 0,
  serviceAmount: 499,
  serviceDiscount: 0,
  walletAmountUsed: 0,
  finalAmount: 499,
  customerName: 'Test User',
  customerPhone: '9876543210',
  customerEmail: 'test@example.com',
);
