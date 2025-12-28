// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Darna Restaurant';

  @override
  String get home => 'Home';

  @override
  String get menu => 'Menu';

  @override
  String get cart => 'Cart';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemMode => 'System';

  @override
  String get favorites => 'Favorites';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get checkout => 'Checkout';

  @override
  String get total => 'Total';

  @override
  String get myOrders => 'My Orders';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get search => 'Search dishes...';

  @override
  String get welcome => 'Welcome to Darna';

  @override
  String get fastDelivery => 'Fast Delivery';

  @override
  String get freshFood => 'Fresh Food';

  @override
  String get guestUser => 'Guest User';

  @override
  String get signedIn => 'Signed In';

  @override
  String get guestEmail => 'guest@darna.ma';

  @override
  String get viewAll => 'View All';

  @override
  String get loginToSeeOrders => 'Log in to see orders';

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String get orderHistoryMsg => 'Your order history will appear here';

  @override
  String get orderNum => 'Order #';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get exploreMenu => 'Explore Menu';

  @override
  String get noFavorites => 'No Favorites Yet';

  @override
  String get saveFavoritesMsg => 'Save your favorite dishes here';

  @override
  String get clearAll => 'Clear All';

  @override
  String get clearedFavorites => 'Cleared all favorites';

  @override
  String get picksForYou => 'Picks For You';

  @override
  String get deliveringTo => 'Delivering to';

  @override
  String get searchPlaceholder => 'Search for dishes...';

  @override
  String get categories => 'Categories';

  @override
  String get seeAll => 'See All';

  @override
  String get loadingDishDetails => 'Loading dish details...';

  @override
  String get error => 'Error';

  @override
  String get failedToLoadProduct => 'Failed to load product details';

  @override
  String get goBack => 'Go Back';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get reviews => 'reviews';

  @override
  String get description => 'Description';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get nutritionalInfo => 'Nutritional Information';

  @override
  String get calories => 'Calories';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Carbohydrates';

  @override
  String get fats => 'Fats';

  @override
  String get portionSize => 'Portion Size';

  @override
  String get spiceLevelOptional => 'Spice Level (Optional)';

  @override
  String get addOns => 'Add-ons';

  @override
  String get specialInstructions => 'Special Instructions';

  @override
  String get specialInstructionsHint =>
      'Any special requests? (e.g., no onions)';

  @override
  String addedProductToCart(String productName) {
    return 'Added $productName to cart!';
  }

  @override
  String get viewCart => 'VIEW CART';

  @override
  String get catTagines => 'Tagines';

  @override
  String get catCouscous => 'Couscous';

  @override
  String get catPastilla => 'Pastilla';

  @override
  String get catStarters => 'Starters';

  @override
  String get catGrills => 'Grills';

  @override
  String get catDesserts => 'Desserts';

  @override
  String get catDrinks => 'Drinks';

  @override
  String get shoppingCart => 'Shopping Cart';

  @override
  String get clear => 'Clear';

  @override
  String get clearCartConfirmTitle => 'Clear Cart?';

  @override
  String get clearCartConfirmMsg =>
      'Are you sure you want to remove all items from your cart?';

  @override
  String get cancel => 'Cancel';

  @override
  String get yourCartIsEmpty => 'Your Cart is Empty';

  @override
  String get addItemsToCartMsg => 'Add delicious dishes to get started';

  @override
  String get browseMenu => 'Browse Menu';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get deliveryFee => 'Delivery Fee';

  @override
  String get freeDelivery => 'FREE';

  @override
  String freeDeliveryMsg(String amount) {
    return 'Add $amount DH more for free delivery';
  }

  @override
  String get proceedToCheckout => 'Proceed to Checkout';

  @override
  String get comingSoon => 'Coming Soon!';

  @override
  String get checkoutComingSoonMsg =>
      'Checkout and payment features are under development. Stay tuned for the complete ordering experience!';

  @override
  String get gotIt => 'Got it';

  @override
  String get enterAddressHint => 'Enter street address, apartment...';

  @override
  String get phoneHint => 'Phone number for delivery';

  @override
  String get cod => 'Cash on Delivery (COD)';

  @override
  String get creditCard => 'Credit Card';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get orderPlacedTitle => 'Order Placed! 🎉';

  @override
  String get orderPlacedMsg =>
      'Your order has been received and is being prepared.';

  @override
  String get ok => 'OK';

  @override
  String get aiChefTitle => 'Darna AI Chef';

  @override
  String get typing => 'Typing...';

  @override
  String get online => 'Online';

  @override
  String get chefThinking => 'Chef is thinking...';

  @override
  String get askMenuHint => 'Ask about our menu...';

  @override
  String get pleaseLoginOrders => 'Please log in to view orders';

  @override
  String moreItems(int count) {
    return '+ $count more items';
  }

  @override
  String orderId(String id) {
    return 'Order #$id';
  }

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusPreparing => 'Preparing';

  @override
  String get statusOutForDelivery => 'Out for Delivery';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get enterAddressError => 'Please enter a delivery address';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get orderStatusTitle => 'Order Status';

  @override
  String get orderPlaced => 'Order Placed';

  @override
  String get estimatedDelivery => 'Estimated';

  @override
  String get confirm => 'Confirm';
}
