import 'dart:async'; // Add import for StreamController

// ... rest of file (same content as above, just ensuring imports are correct)
import 'package:fpdart/fpdart.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/app_user.dart';
import 'package:darna/core/error/failures.dart'; // Fixed import
import 'package:darna/core/utils/either_extension.dart';

class MockAuthRepository implements AuthRepository {
  AppUser? _currentUser;
  final _authStateController = StreamController<AppUser?>.broadcast();
  
  // Reuse content from previous step...
  final _mockUser = AppUser(
    id: 'user_123',
    email: 'client@darna.ma',
    name: 'Karim Benali',
    role: 'client',
    createdAt: DateTime.now(),
  );

  final _mockAdmin = AppUser(
    id: 'admin_123',
    email: 'admin@darna.ma',
    name: 'Darna Admin',
    role: 'restaurant',
    createdAt: DateTime.now(),
  );

  MockAuthRepository() {
    Future.delayed(const Duration(seconds: 1), () {
      _authStateController.add(null);
    });
  }

  @override
  Stream<AppUser?> get authStateChanges => _authStateController.stream;

  @override
  Future<AppUser?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  FutureEither<AppUser> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (email == 'admin@darna.ma' && password == 'DarnaAdmin2024!') {
      _currentUser = _mockAdmin;
      _authStateController.add(_currentUser);
      return Right(_currentUser!);
    } else if (password.length >= 6) {
      _currentUser = _mockUser.copyWith(email: email);
      _authStateController.add(_currentUser);
      return Right(_currentUser!);
    } else {
      return Left(const AuthFailure('Invalid credentials'));
    }
  }

  @override
  FutureEither<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUser = AppUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      phone: phone ?? '',
      role: 'client',
      createdAt: DateTime.now(),
    );
    
    _authStateController.add(_currentUser);
    return Right(_currentUser!);
  }

  @override
  FutureEither<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _authStateController.add(null);
    return const Right(null);
  }

  @override
  FutureEither<AppUser> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? preferredLanguage,
  }) async {
    if (_currentUser == null) return Left(const AuthFailure('No user logged in'));
    
    _currentUser = _currentUser!.copyWith(
      name: name,
      phone: phone,
      preferredLanguage: preferredLanguage,
    );
    
    _authStateController.add(_currentUser);
    return Right(_currentUser!);
  }

  @override
  FutureEither<void> addToFavorites({required String userId, required String productId}) async {
    if (_currentUser == null) return Left(const AuthFailure('No user logged in'));
    
    final newFavorites = List<String>.from(_currentUser!.favoriteProductIds)..add(productId);
    _currentUser = _currentUser!.copyWith(favoriteProductIds: newFavorites);
    _authStateController.add(_currentUser);
    return const Right(null);
  }

  @override
  FutureEither<void> removeFromFavorites({required String userId, required String productId}) async {
    if (_currentUser == null) return Left(const AuthFailure('No user logged in'));
    
    final newFavorites = List<String>.from(_currentUser!.favoriteProductIds)..remove(productId);
    _currentUser = _currentUser!.copyWith(favoriteProductIds: newFavorites);
    _authStateController.add(_currentUser);
    return const Right(null);
  }
}
