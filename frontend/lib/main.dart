import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'providers/auth_provider.dart';
import 'providers/menu_provider.dart';
import 'services/graphql_service.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/create_restaurant_screen.dart';
import 'screens/auth/join_restaurant_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for GraphQL caching
  await Hive.initFlutter();
  await initHiveForFlutter();
  
  // Initialize GraphQL service
  GraphQLService.instance.initialize();
  
  runApp(const RestaurantApp());
}

class RestaurantApp extends StatefulWidget {
  const RestaurantApp({super.key});

  @override
  State<RestaurantApp> createState() => _RestaurantAppState();
}

class _RestaurantAppState extends State<RestaurantApp> {
  late final GoRouter _router;
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    
    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: _authProvider, // Listen to auth state changes
      redirect: (context, state) {
        final isLoggedIn = _authProvider.isLoggedIn;
        final isAuthRoute = [
          '/',
          '/create-restaurant',
          '/join-restaurant',
          '/verify-email',
          '/sign-in'
        ].contains(state.matchedLocation.split('?')[0]);

        if (isLoggedIn && isAuthRoute) {
          return '/home';
        }
        if (!isLoggedIn && !isAuthRoute) {
          return '/';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/create-restaurant',
          builder: (context, state) => const CreateRestaurantScreen(),
        ),
        GoRoute(
          path: '/join-restaurant',
          builder: (context, state) => const JoinRestaurantScreen(),
        ),
        GoRoute(
          path: '/verify-email',
          builder: (context, state) {
            final email = state.uri.queryParameters['email'] ?? '';
            return EmailVerificationScreen(email: email);
          },
        ),
        GoRoute(
          path: '/sign-in',
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    );

    // Initialize auth state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authProvider.initializeAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => _authProvider,
        ),
        ChangeNotifierProvider<MenuProvider>(
          create: (_) => MenuProvider(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            title: 'Restaurant Manager',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.indigo,
              primaryColor: Colors.indigo,
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.light,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.indigo,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            routerConfig: _router,
          );
        },
      ),
    );
  }
}