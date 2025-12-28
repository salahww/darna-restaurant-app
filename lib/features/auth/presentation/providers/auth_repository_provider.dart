import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/mock_auth_repository.dart';
// import '../../data/repositories/firebase_auth_repository.dart'; // TODO: Implement this next

/// Provider for AuthRepository
/// Currently using MockAuthRepository until FirebaseAuthRepository is implemented
/// This allows us to keep the app runnable while we build the auth layer
final authRepositoryProvider = Provider<AuthRepository>((ref) {
    return MockAuthRepository(); 
});
