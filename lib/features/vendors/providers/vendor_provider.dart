import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/vendor_service.dart';

final vendorServiceProvider = Provider<VendorService>((ref) => VendorService());
