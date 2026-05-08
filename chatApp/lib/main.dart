// lib/main.dart
import 'dart:async';
import 'package:chatapp/presentation/home/home_screen.dart';
import 'package:chatapp/presentation/router/app_router.dart';
import 'package:chatapp/presentation/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'config/theme/app_theme.dart';
import 'data/repositories/chat_repository.dart';
import 'data/services/service_locator.dart';
import 'logic/cubits/auth/auth_cubit.dart';
import 'logic/cubits/auth/auth_state.dart';
import 'logic/observer/app_life_cycle_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();

  // Request contacts permission at startup
  await _requestContactsPermissionAtStartup();

  runApp(const MyApp());
}

/// Request contacts permission at app startup (non-blocking)
Future<void> _requestContactsPermissionAtStartup() async {
  try {
    final status = await Permission.contacts.request();
    print('[Startup] Contacts permission request result: $status');

    // Also verify flutter_contacts can access
    if (status.isGranted) {
      try {
        final contacts = await FlutterContacts.getContacts(withProperties: false);
        print('[Startup] Flutter contacts access verified: ${contacts.length} contacts');
      } catch (e) {
        print('[Startup] Flutter contacts access failed: $e');
      }
    }
  } catch (e) {
    print('[Startup] Error requesting contacts permission: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  AppLifeCycleObserver? _lifeCycleObserver;
  late final StreamSubscription _authSub;

  @override
  void initState() {
    super.initState();

    // Listen to auth state changes and attach/detach lifecycle observer when user signs in/out
    _authSub = getIt<AuthCubit>().stream.listen((state) {
      if (state.status == AuthStatus.authenticated && state.user != null) {
        // Remove any existing observer first
        if (_lifeCycleObserver != null) {
          WidgetsBinding.instance.removeObserver(_lifeCycleObserver!);
        }

        _lifeCycleObserver = AppLifeCycleObserver(
            userId: state.user!.uid, chatRepository: getIt<ChatRepository>());
        WidgetsBinding.instance.addObserver(_lifeCycleObserver!);
      } else {
        // If signed out or unauthenticated, remove observer if present
        if (_lifeCycleObserver != null) {
          WidgetsBinding.instance.removeObserver(_lifeCycleObserver!);
          _lifeCycleObserver = null;
        }
      }
    });
  }

  @override
  void dispose() {
    // Clean up auth subscription and lifecycle observer
    _authSub.cancel();
    if (_lifeCycleObserver != null) {
      WidgetsBinding.instance.removeObserver(_lifeCycleObserver!);
      _lifeCycleObserver = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        title: 'Messenger App',
        navigatorKey: getIt<AppRouter>().navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthCubit, AuthState>(
          bloc: getIt<AuthCubit>(),
          builder: (context, state) {
            if (state.status == AuthStatus.initial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (state.status == AuthStatus.authenticated) {
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
