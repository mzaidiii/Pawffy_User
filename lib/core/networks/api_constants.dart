class ApiConstants {
  static const String baseUrl = 'https://pawffy-backend.onrender.com';

  // ── Auth ──────────────────────────────────────────
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String me = '/api/auth/me';
  static const String logout = '/api/auth/logout';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String changePassword = '/api/auth/change-password';

  // ── Users ─────────────────────────────────────────
  static const String updateMe = '/api/users/me';
  static const String uploadAvatar = '/api/users/me/avatar';

  // ── Pets ──────────────────────────────────────────
  static const String pets = '/api/pets';
  static String petById(String id) => '/api/pets/$id';
  static String uploadPetImage(String id) => '/api/pets/$id/image';

  // ── Vets ──────────────────────────────────────────
  static const String vets = '/api/vets';
  static String vetById(String id) => '/api/vets/$id';
  static String vetAvailability(String id) => '/api/vets/$id/availability';
  static String vetSlots(String id) => '/api/vets/$id/slots';
  static String vetServices(String id) => '/api/vets/$id/services';
  static String vetReviews(String id) => '/api/vets/$id/reviews';

  // ── Bookings ──────────────────────────────────────
  static const String bookings = '/api/bookings';
  static String bookingById(String id) => '/api/bookings/$id';
  static String updateBookingStatus(String id) => '/api/bookings/$id/status';

  // ── Messages ──────────────────────────────────────
  static const String conversations = '/api/messages/conversations';
  static const String sendMessage = '/api/messages';
  static String startChat(String receiverId) =>
      '/api/messages/conversation/with/$receiverId';
  static String messagesByConversation(String id) => '/api/messages/$id';
  static String markConversationRead(String id) => '/api/messages/$id/read';

  // ── Payments ──────────────────────────────────────
  static const String createPaymentIntent = '/api/payments/create-intent';
  static const String confirmWalletPayment = '/api/payments/confirm';
  static const String verifyStripePayment = '/api/payments/verify';
  static const String applyCoupon = '/api/payments/apply-coupon';
  static String paymentSummary(String id) => '/api/payments/summary/$id';
  static String paymentByBooking(String id) => '/api/payments/booking/$id';

  // ── Medical Records ───────────────────────────────
  static const String medicalRecords = '/api/medical-records';
  static String medicalRecordById(String id) => '/api/medical-records/$id';
  static String medicalRecordsByPet(String id) =>
      '/api/medical-records/pet/$id';

  // ── Vaccinations ──────────────────────────────────
  static const String vaccinations = '/api/vaccinations';
  static String vaccinationById(String id) => '/api/vaccinations/$id';
  static String vaccinationsByPet(String id) => '/api/vaccinations/pet/$id';

  // ── Notifications ─────────────────────────────────
  static const String notifications = '/api/notifications';
  static const String markAllNotificationsRead = '/api/notifications/read-all';
  static String markNotificationRead(String id) =>
      '/api/notifications/$id/read';
  static String deleteNotification(String id) => '/api/notifications/$id';
}
