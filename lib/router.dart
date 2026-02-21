import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/recipes_screen.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/web_shopping_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState;
      final isLoginPage = state.matchedLocation == '/login';

      // If not logged in and not on login page, redirect to login
      if (!isLoggedIn && !isLoginPage) {
        return '/login';
      }

      // If logged in and on login page, redirect to home
      if (isLoggedIn && isLoginPage) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/recipes',
        builder: (context, state) => const RecipesScreen(),
      ),
      GoRoute(
        path: '/shopping',
        builder: (context, state) => const ShoppingListScreen(),
      ),
      GoRoute(
        path: '/web-shopping',
        builder: (context, state) => const WebShoppingScreen(),
      ),
    ],
  );
});
