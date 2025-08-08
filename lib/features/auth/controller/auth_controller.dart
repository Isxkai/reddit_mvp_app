import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/repository/auth_repository.dart';
import 'package:reddit_clone/models/user_model.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  ),
);

final authStateChangesProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChanges;
});

final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;
  AuthController({required AuthRepository authRepository, required Ref ref})
    : _authRepository = authRepository,
      _ref = ref,
      super(false); //loading

  Stream<User?> get authStateChanges => _authRepository.authStateChanges;

  void signInWithGoogle(BuildContext context) async {
    try {
      state = true;
      print('Starting Google Sign In'); // Debug print
      final user = await _authRepository.signInWithGoogle();
      state = false;

      user.fold(
        (failure) {
          print('Sign in failed: ${failure.message}'); // Debug print
          if (context.mounted) {
            showSnackBar(context, failure.message);
          }
        },
        (userModel) {
          print('Sign in successful: ${userModel.uid}'); // Debug print
          _ref.read(userProvider.notifier).update((state) => userModel);
        },
      );
    } catch (e) {
      state = false;
      print('Unexpected error in signInWithGoogle: $e'); // Debug print
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }

  void logOut() async {
   _authRepository.logOut();
      
  }
}
