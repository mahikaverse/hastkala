import 'package:flutter/material.dart';

import '../core/models/user_role.dart';
import '../core/widgets/app_scaffold.dart';
import '../features/artisan/presentation/artisan_home_screen.dart';
import '../features/artisan/presentation/artisan_profile_screen.dart';
import '../features/artisan/presentation/manage_products_screen.dart';
import '../features/artisan_store/presentation/screens/artisan_dashboard_screen.dart';
import '../features/artisan_store/presentation/screens/artisan_store_screen.dart';
import '../features/artisan_store/presentation/screens/voice_add_product_screen.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/buyer/presentation/buyer_home_screen.dart';
import '../features/cart/presentation/cart_screen.dart';
import '../features/catalog/presentation/ai_pricing_screen.dart';
import '../features/catalog/presentation/ai_image_studio_screen.dart';
import '../features/catalog/presentation/ai_product_studio_screen.dart';
import '../features/products/screens/custom_camera_screen.dart';
import '../features/catalog/presentation/catalog_screen.dart';
import '../features/catalog/presentation/market_linkage_screen.dart';
import '../features/catalog/presentation/publish_product_screen.dart';
import '../features/checkout/presentation/checkout_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/marketplace/presentation/screens/explore_artisans_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/orders/presentation/artisan_orders_screen.dart';
import '../features/orders/presentation/order_tracking_screen.dart';
import '../features/products/presentation/product_details_screen.dart';
import '../features/products/presentation/product_listing_screen.dart';
import '../features/products/screens/artisan_add_product_screen.dart';
import '../features/products/screens/voice_step1_details_screen.dart';
import '../features/products/screens/voice_step2_quantity_screen.dart';
import '../features/products/screens/voice_step3_story_screen.dart';
import '../features/products/screens/tell_about_product_screen.dart';
import '../features/products/screens/review_details_screen.dart';
import '../features/products/screens/catalog_preview_screen.dart';
import '../features/products/screens/set_price_screen.dart';
import '../features/products/screens/ai_price_assistant_screen.dart';
import '../features/products/screens/ready_to_publish_screen.dart';
import '../features/products/screens/publish_success_screen.dart';
import '../features/products/models/product_draft.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/role_selection/presentation/role_selection_screen.dart';
import '../features/splash/presentation/splash_screen.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String roleSelection = '/role-selection';
  static const String sellerAuth = '/seller-auth';
  static const String buyerAuth = '/buyer-auth';
  static const String home = '/home';
  static const String buyerHome = '/buyer-home';
  static const String artisanHome = '/artisan-home';
  static const String productListing = '/product-listing';
  static const String productDetails = '/product-details';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderTracking = '/order-tracking';
  static const String profile = '/profile';
  static const String artisanProfile = '/artisan-profile';
  static const String artisanAddProduct = '/artisan-add-product';
  static const String aiImageStudio = '/ai-image-studio';
  static const String customCamera = '/custom-camera';
  static const String aiProductStudio = '/ai-product-studio';
  static const String smartCatalog = '/smart-catalog';
  static const String aiPricing = '/ai-pricing';
  static const String marketLinkage = '/market-linkage';
  static const String manageProducts = '/manage-products';
  static const String artisanOrders = '/artisan-orders';
  static const String publishProduct = '/publish-product';

  // New marketplace routes
  static const String artisanDashboard = '/artisan-dashboard';
  static const String artisanStore = '/artisan-store';
  static const String exploreArtisans = '/explore-artisans';
  static const String voiceStep1Details = '/voice-step-1';
  static const String voiceStep2Quantity = '/voice-step-2';
  static const String voiceStep3Story = '/voice-step-3';
  static const String tellAboutProduct = '/tell-about-product';
  static const String reviewDetails = '/review-details';
  static const String catalogPreview = '/catalog-preview';
  static const String setPrice = '/set-price';
  static const String aiPriceAssistant = '/ai-price-assistant';
  static const String readyToPublish = '/ready-to-publish';
  static const String publishSuccess = '/publish-success';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(const SplashScreen(), settings: settings);
      case AppRoutes.onboarding:
        return _buildRoute(const OnboardingScreen(), settings: settings);
      case AppRoutes.login:
        final role = settings.arguments as UserRole?;
        return _buildRoute(LoginScreen(initialRole: role), settings: settings);
      case AppRoutes.roleSelection:
        return _buildRoute(const RoleSelectionScreen(), settings: settings);
      case AppRoutes.sellerAuth:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const LoginScreen(initialRole: UserRole.seller),
        );
      case AppRoutes.buyerAuth:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const LoginScreen(initialRole: UserRole.buyer),
        );
      case AppRoutes.home:
        return _buildRoute(const HomeScreen(), settings: settings);
      case AppRoutes.buyerHome:
        return _buildRoute(const BuyerHomeScreen(), settings: settings);
      case AppRoutes.artisanHome:
        return _buildRoute(const ArtisanHomeScreen(), settings: settings);
      case AppRoutes.productListing:
        return _buildRoute(const ProductListingScreen(), settings: settings);
      case AppRoutes.productDetails:
        final product = settings.arguments as dynamic;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ProductDetailsScreen(product: product),
        );
      case AppRoutes.cart:
        return _buildRoute(const CartScreen(), settings: settings);
      case AppRoutes.checkout:
        return _buildRoute(const CheckoutScreen(), settings: settings);
      case AppRoutes.orderTracking:
        return _buildRoute(const OrderTrackingScreen(), settings: settings);
      case AppRoutes.profile:
        return _buildRoute(const ProfileScreen(), settings: settings);
      case AppRoutes.artisanProfile:
        return _buildRoute(const ArtisanProfileScreen(), settings: settings);
      case AppRoutes.artisanAddProduct:
        return _buildRoute(const ArtisanAddProductScreen(), settings: settings);
      case AppRoutes.aiImageStudio:
        final imagePath = settings.arguments as String?;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => AIImageStudioScreen(imagePath: imagePath),
        );
      case AppRoutes.customCamera:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const CustomCameraScreen(),
        );
      case AppRoutes.aiProductStudio:
        return _buildRoute(const AIProductStudioScreen(), settings: settings);
      case AppRoutes.smartCatalog:
        return _buildRoute(const CatalogScreen(), settings: settings);
      case AppRoutes.aiPricing:
        return _buildRoute(const AIPricingScreen(), settings: settings);
      case AppRoutes.marketLinkage:
        return _buildRoute(const MarketLinkageScreen(), settings: settings);
      case AppRoutes.manageProducts:
        return _buildRoute(const ManageProductsScreen(), settings: settings);
      case AppRoutes.artisanOrders:
        return _buildRoute(const ArtisanOrdersScreen(), settings: settings);
      case AppRoutes.publishProduct:
        return _buildRoute(const PublishProductScreen(), settings: settings);

      // New marketplace routes
      case AppRoutes.artisanDashboard:
        return _buildRoute(const ArtisanDashboardScreen(), settings: settings);
      case AppRoutes.artisanStore:
        final slug = settings.arguments as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ArtisanStoreScreen(storeSlug: slug),
        );
      case AppRoutes.exploreArtisans:
        return _buildRoute(const ExploreArtisansScreen(), settings: settings);
      case AppRoutes.voiceAddProduct:
        return _buildRoute(const VoiceAddProductScreen(), settings: settings);
      case AppRoutes.voiceStep1Details:
      case AppRoutes.tellAboutProduct:
        final draft = settings.arguments as ProductDraft;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => VoiceStep1DetailsScreen(draft: draft),
        );
      case AppRoutes.voiceStep2Quantity:
        final draft = settings.arguments as ProductDraft;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => VoiceStep2QuantityScreen(draft: draft),
        );
      case AppRoutes.voiceStep3Story:
        final draft = settings.arguments as ProductDraft;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => VoiceStep3StoryScreen(draft: draft),
        );
      case AppRoutes.reviewDetails:
        final draft = settings.arguments as ProductDraft;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ReviewDetailsScreen(draft: draft),
        );
      case AppRoutes.catalogPreview:
        final draft = settings.arguments as ProductDraft;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => CatalogPreviewScreen(draft: draft),
        );
      case AppRoutes.setPrice:
        final draft = settings.arguments as ProductDraft;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => SetPriceScreen(draft: draft),
        );
      case AppRoutes.aiPriceAssistant:
        final draft = settings.arguments as ProductDraft;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => AIPriceAssistantScreen(draft: draft),
        );
      case AppRoutes.readyToPublish:
        final draft = settings.arguments as ProductDraft;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ReadyToPublishScreen(draft: draft),
        );
      case AppRoutes.publishSuccess:
        final draft = settings.arguments as ProductDraft;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => PublishSuccessScreen(draft: draft),
        );

      default:
        return _buildRoute(_NotFoundScreen(routeName: settings.name ?? 'unknown'), settings: settings);
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, {required RouteSettings settings}) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({required this.routeName});
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: HastKalaAppBar(title: 'Not Found', showBackButton: true),
      body: Center(child: Text('Page not found: $routeName')),
    );
  }
}
