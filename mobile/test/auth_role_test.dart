import 'package:flutter_test/flutter_test.dart';
import 'package:hastkala/app/router.dart';
import 'package:hastkala/core/models/user_role.dart';
import 'package:hastkala/core/services/auth_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('UserRole and Auth Mapping Tests', () {
    test('UserRole parsing from strings works correctly', () {
      expect(UserRole.fromString('artisan'), UserRole.seller);
      expect(UserRole.fromString('seller'), UserRole.seller);
      expect(UserRole.fromString('b2b_seller'), UserRole.b2bSeller);
      expect(UserRole.fromString('b2b'), UserRole.b2bSeller);
      expect(UserRole.fromString('buyer'), UserRole.buyer);
      expect(UserRole.fromString('customer'), UserRole.buyer);
      expect(UserRole.fromString(null), UserRole.buyer);
    });

    test('UserRole dbValue returns correct schema strings', () {
      expect(UserRole.seller.dbValue, 'artisan');
      expect(UserRole.b2bSeller.dbValue, 'b2b_seller');
      expect(UserRole.buyer.dbValue, 'buyer');
    });

    test('AuthService routes roles to correct dashboards', () {
      final auth = AuthService();
      expect(auth.getHomeRouteForRole(UserRole.seller), AppRoutes.artisanDashboard);
      expect(auth.getHomeRouteForRole(UserRole.b2bSeller), AppRoutes.artisanDashboard);
      expect(auth.getHomeRouteForRole(UserRole.buyer), AppRoutes.buyerHome);
    });
  });
}
