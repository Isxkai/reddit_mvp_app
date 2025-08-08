import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/firebase_options.dart';
import 'package:reddit_clone/router.dart';
import 'package:reddit_clone/theme/pallet.dart';
import 'package:routemaster/routemaster.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // Add this flag
  bool _isFirstBuild = true;

  void getData(User user) async {
    try {
      if (_isFirstBuild) {
        print('Getting data for user: ${user.uid}');
      }
      final userModel =
          await ref
              .read(authControllerProvider.notifier)
              .getUserData(user.uid)
              .first;
      if (_isFirstBuild) {
        print('User model fetched: ${userModel.uid}');
      }

      if (mounted) {
        ref.read(userProvider.notifier).update((state) => userModel);
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(authStateChangesProvider)
        .when(
          data: (user) {
            if (_isFirstBuild) {
              print('Auth state changed: ${user?.uid}');
              _isFirstBuild = false;
            }

            if (user != null) {
              getData(user);
            }

            final currentUser = ref.watch(userProvider);

            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Reddit Clone',
              theme: ref.watch(themeNotifierProvider),
              routerDelegate: RoutemasterDelegate(
                routesBuilder: (context) {
                  if (currentUser != null) {
                    return loggedInRoute;
                  }
                  return loggedOutRoute;
                },
              ),
              routeInformationParser: const RoutemasterParser(),
            );
          },
          error:
              (error, stackTrace) =>
                  MaterialApp(home: ErrorText(error: error.toString())),
          loading: () => const MaterialApp(home: Loader()),
        );
  }
}
