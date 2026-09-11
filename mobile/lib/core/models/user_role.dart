enum UserRole {
  seller,
  b2bSeller,
  buyer;

  String get dbValue {
    switch (this) {
      case UserRole.seller:
        return 'artisan';
      case UserRole.b2bSeller:
        return 'b2b_seller';
      case UserRole.buyer:
        return 'buyer';
    }
  }

  static UserRole fromString(String? role) {
    if (role == null) return UserRole.buyer;
    final r = role.toLowerCase().trim();
    if (r == 'artisan' || r == 'seller') {
      return UserRole.seller;
    } else if (r == 'b2b_seller' || r == 'b2bseller' || r == 'b2b') {
      return UserRole.b2bSeller;
    } else {
      return UserRole.buyer;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.seller:
        return 'Artisan / Maker';
      case UserRole.b2bSeller:
        return 'B2B Wholesale Seller';
      case UserRole.buyer:
        return 'Buyer / Customer';
    }
  }

  String get shortTitle {
    switch (this) {
      case UserRole.seller:
        return 'Artisan';
      case UserRole.b2bSeller:
        return 'B2B Seller';
      case UserRole.buyer:
        return 'Buyer';
    }
  }
}

