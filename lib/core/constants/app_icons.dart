import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';

/// Centralized icon constants using Iconsax for consistent premium UI
/// 
/// Usage:
/// ```dart
/// Icon(AppIcons.home)
/// Icon(AppIcons.homeActive)
/// ```
class AppIcons {
  AppIcons._();

  // ========== NAVIGATION ==========
  
  /// Home icon
  static const IconData home = Iconsax.home_2;
  static const IconData homeActive = Iconsax.home5;
  
  /// Favorites/Wishlist
  static const IconData favorites = Iconsax.heart;
  static const IconData favoritesActive = Iconsax.heart5;
  
  /// Cart/Basket
  static const IconData cart = Iconsax.shopping_cart;
  static const IconData cartActive = Iconsax.shopping_cart5;
  
  /// AI Assistant
  static const IconData ai = Iconsax.magic_star;
  static const IconData aiActive = Iconsax.magic_star5;
  
  /// Profile/Account
  static const IconData profile = Iconsax.profile_circle;
  static const IconData profileActive = Iconsax.profile_circle5;
  
  /// Orders
  static const IconData orders = Iconsax.receipt_item;
  static const IconData ordersActive = Iconsax.receipt_item5;
  
  /// Settings
  static const IconData settings = Iconsax.setting_2;
  static const IconData settingsActive = Iconsax.setting_25;

  // ========== FOOD CATEGORIES ==========
  
  /// All Menu
  static const IconData allMenu = Iconsax.menu_board;
  
  /// Tagine (main dish)
  static const IconData tagine = Iconsax.chart;
  
  /// Couscous
  static const IconData couscous = Iconsax.cake;
  
  /// Grills/BBQ
  static const IconData grills = Iconsax.directbox_default;
  
  /// Drinks
  static const IconData drinks = Iconsax.coffee;
  
  /// Desserts
  static const IconData desserts = Iconsax.cake;
  
  /// Salads
  static const IconData salads = Iconsax.lovely;
  
  /// Appetizers
  static const IconData appetizers = Iconsax.box_1;
  
  /// Soup
  static const IconData soup = Iconsax.drop;
  
  /// Restaurant/Food general
  static const IconData food = Iconsax.reserve;

  // ========== ACTIONS ==========
  
  /// Add/Plus
  static const IconData add = Iconsax.add;
  static const IconData addCircle = Iconsax.add_circle;
  
  /// Minus/Remove
  static const IconData minus = Iconsax.minus;
  static const IconData remove = Iconsax.trash;
  
  /// Search
  static const IconData search = Iconsax.search_normal_1;
  
  /// Filter
  static const IconData filter = Iconsax.filter;
  static const IconData filterEdit = Iconsax.filter_edit;
  
  /// Edit
  static const IconData edit = Iconsax.edit_2;
  
  /// Delete
  static const IconData delete = Iconsax.trash;
  
  /// Close/Cancel
  static const IconData close = Iconsax.close_circle;
  
  /// Check/Confirm
  static const IconData check = Iconsax.tick_circle;
  
  /// Share
  static const IconData share = Iconsax.share;
  
  /// Send
  static const IconData send = Iconsax.send_1;
  
  /// Refresh
  static const IconData refresh = Iconsax.refresh;
  
  /// Copy
  static const IconData copy = Iconsax.copy;

  // ========== STATUS & INFO ==========
  
  /// Notification
  static const IconData notification = Iconsax.notification;
  static const IconData notificationActive = Iconsax.notification5;
  
  /// Location/Map
  static const IconData location = Iconsax.location;
  static const IconData locationActive = Iconsax.location5;
  
  /// Clock/Time
  static const IconData clock = Iconsax.clock;
  
  /// Calendar
  static const IconData calendar = Iconsax.calendar;
  
  /// Star/Rating
  static const IconData star = Iconsax.star5;
  static const IconData starOutline = Iconsax.star;
  
  /// Info
  static const IconData info = Iconsax.info_circle;
  
  /// Warning
  static const IconData warning = Iconsax.warning_2;
  
  /// Error/Danger
  static const IconData error = Iconsax.danger;
  
  /// Success
  static const IconData success = Iconsax.tick_circle;

  // ========== DELIVERY & ORDER ==========
  
  /// Delivery Truck
  static const IconData delivery = Iconsax.truck_fast;
  
  /// Package/Order
  static const IconData package = Iconsax.box;
  
  /// Motorcycle (for delivery)
  static const IconData motorcycle = Iconsax.car;
  
  /// Map/Route
  static const IconData route = Iconsax.routing_2;
  
  /// Tracking
  static const IconData tracking = Iconsax.gps;
  
  /// Receipt
  static const IconData receipt = Iconsax.receipt_2;

  // ========== PAYMENT ==========
  
  /// Wallet
  static const IconData wallet = Iconsax.wallet_2;
  
  /// Credit Card
  static const IconData creditCard = Iconsax.card;
  
  /// Cash
  static const IconData cash = Iconsax.money;
  
  /// Discount/Coupon
  static const IconData discount = Iconsax.discount_shape;
  static const IconData gift = Iconsax.gift;

  // ========== CONTACT & COMMUNICATION ==========
  
  /// Phone/Call
  static const IconData phone = Iconsax.call;
  
  /// Message/Chat
  static const IconData message = Iconsax.message;
  static const IconData messageActive = Iconsax.message5;
  
  /// Email
  static const IconData email = Iconsax.sms;
  
  /// Help/Support
  static const IconData help = Iconsax.message_question;

  // ========== USER & PROFILE ==========
  
  /// User
  static const IconData user = Iconsax.user;
  
  /// Users/Group
  static const IconData users = Iconsax.people;
  
  /// Camera
  static const IconData camera = Iconsax.camera;
  
  /// Gallery/Image
  static const IconData gallery = Iconsax.gallery;
  
  /// Language
  static const IconData language = Iconsax.global;
  
  /// Dark Mode
  static const IconData darkMode = Iconsax.moon;
  
  /// Light Mode
  static const IconData lightMode = Iconsax.sun_1;
  
  /// Logout
  static const IconData logout = Iconsax.logout;
  
  /// Login
  static const IconData login = Iconsax.login;

  // ========== NAVIGATION ARROWS ==========
  
  /// Arrow Right
  static const IconData arrowRight = Iconsax.arrow_right_3;
  
  /// Arrow Left
  static const IconData arrowLeft = Iconsax.arrow_left_2;
  
  /// Arrow Up
  static const IconData arrowUp = Iconsax.arrow_up_2;
  
  /// Arrow Down
  static const IconData arrowDown = Iconsax.arrow_down_2;
  
  /// Chevron Right
  static const IconData chevronRight = Iconsax.arrow_right_3;
  
  /// Chevron Left
  static const IconData chevronLeft = Iconsax.arrow_left_2;
  
  /// Back
  static const IconData back = Iconsax.arrow_left_2;
  
  /// Forward
  static const IconData forward = Iconsax.arrow_right_3;

  // ========== MISC ==========
  
  /// Menu/Hamburger
  static const IconData menu = Iconsax.menu_1;
  
  /// More (3 dots)
  static const IconData more = Iconsax.more;
  static const IconData moreCircle = Iconsax.more_circle;
  
  /// Grid View
  static const IconData grid = Iconsax.element_3;
  
  /// List View
  static const IconData list = Iconsax.textalign_justifyleft;
  
  /// Eye/View
  static const IconData eye = Iconsax.eye;
  static const IconData eyeOff = Iconsax.eye_slash;
  
  /// Lock/Security
  static const IconData lock = Iconsax.lock;
  static const IconData unlock = Iconsax.unlock;
  
  /// Document
  static const IconData document = Iconsax.document;
  
  /// Terms/Policy
  static const IconData terms = Iconsax.document_text;
  
  /// About
  static const IconData about = Iconsax.info_circle;
}
