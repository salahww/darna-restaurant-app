import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to manage main navigation tab index
final mainNavigationIndexProvider = StateProvider<int>((ref) => 0);
