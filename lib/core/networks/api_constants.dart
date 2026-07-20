class ApiConstants {
  static const String baseUrl = 'https://pawffy-backend-yyed.onrender.com';

  // Supabase Configuration
  static const String supabaseUrl = 'https://hnwslusckrzbnulxwgwp.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_nuKdWOHmpNp87YsximpVVw_1Huju3QL';
  // ── Auth ──────────────────────────────────────────
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String session = '/api/auth/session';
  static const String me = '/api/auth/me';
  static const String logout = '/api/auth/logout';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String changePassword = '/api/auth/change-password';

  // ── Users ─────────────────────────────────────────
  static const String updateMe = '/api/users/me';
  static const String deleteMyAccount = '/api/users/me';
  static const String uploadAvatar = '/api/users/me/avatar';
  static const String users = '/api/users';
  static String userById(String id) => '/api/users/$id';
  static String changeUserRole(String id) => '/api/users/$id/role';
  static const String addresses = '/api/users/me/addresses';
  static String addressById(String id) => '/api/users/me/addresses/$id';
  static String setDefaultAddress(String id) =>
      '/api/users/me/addresses/$id/default';

  // ── Dashboard ─────────────────────────────────────
  static const String dashboard = '/api/dashboard/dashboard';
  static String dashboardUser(String id) => '/api/dashboard/users/$id';
  static const String dashboardPartners = '/api/dashboard/partners';
  static String dashboardNotifications(String id) =>
      '/api/dashboard/notifications/$id';
  static const String dashboardCategories = '/api/dashboard/categories';
  static const String dashboardBanner = '/api/dashboard/banner';

  // ── Lost & Found Pets ─────────────────────────────
  static const String lostPets = '/api/lost-pets';
  static const String lostPetReports = '/api/lost-pets/reports';
  static String lostPetReportById(String id) => '/api/lost-pets/report/$id';
  static const String foundPets = '/api/found-pets';
  static String foundPetById(String id) => '/api/found-pets/$id';
  static const String allPetReports = '/api/reports';

  // ── Pets ──────────────────────────────────────────
  static const String pets = '/api/pets';
  static String petById(String id) => '/api/pets/$id';
  static String uploadPetImage(String id) => '/api/pets/$id/image';

  // ── Vendors (Public Discovery) ────────────────────
  static const String vendors = '/api/vendors';
  static String vendorById(String id) => '/api/vendors/$id';
  static String vendorReviews(String id) => '/api/vendors/$id/reviews';
  static String vendorSlots(String id) => '/api/vendors/$id/slots';
  static String vendorRequests(String id) => '/api/vendors/$id/requests';
  static const String vendorRequestsAsVendor = '/api/vendor/requests';

  // ── Vets (Booking flow — slots/services) ─────────
  // These stay on old /api/vets until vendor equivalents exist

  // ── Bookings ──────────────────────────────────────
  static const String bookings = '/api/bookings';
  static String bookingById(String id) => '/api/bookings/$id';
  static String updateBookingStatus(String id) => '/api/bookings/$id/status';

  // ── Walking Bookings ──────────────────────────────
  static const String walkingBookings = '/api/bookings/walking';
  static String walkingBookingById(String id) => '/api/bookings/walking/$id';

  // ── Messages ──────────────────────────────────────
  static const String conversations = '/api/messages/conversations';
  static const String sendMessage = '/api/messages';
  static String startChat(String receiverId) =>
      '/api/messages/conversation/with/$receiverId';
  static String messagesByConversation(String id) => '/api/messages/$id';
  static String markConversationRead(String id) => '/api/messages/$id/read';

  // ── Payments ──────────────────────────────────────
  static const String paymentConfig = '/api/payments/config';
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

  // ── Wallet ─────────────────────────────────────────
  static const String wallet = '/api/wallet';
  static const String walletTopUp = '/api/wallet/top-up';
  static const String walletTopUpIntent = '/api/wallet/top-up/intent';
  static const String walletTopUpVerify = '/api/wallet/top-up/verify';
  static const String walletWithdraw = '/api/wallet/withdraw';

  // ── Support & Static ──────────────────────────────
  static const String supportTickets = '/api/support/tickets';
  static const String staticTerms = '/api/static/terms';
  static const String staticPrivacy = '/api/static/privacy';
}
