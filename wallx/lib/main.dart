import 'package:flutter/material.dart';
import 'package:wallx/screens/home_screen.dart';
import 'package:wallx/screens/category_screen.dart';
import 'package:wallx/screens/favorites_screen.dart';
import 'package:wallx/screens/ai_screen.dart';
import 'package:wallx/screens/profile_screen.dart';
import 'package:wallx/screens/category_detail_screen.dart';
import 'package:wallx/screens/wallpaper_detail_screen.dart';
import 'package:wallx/widgets/custom_bottom_nav.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallx',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0A192F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0A192F),
          selectedItemColor: Color(0xFF64FFDA),
          unselectedItemColor: Color(0xFF8892B0),
        ),
      ),
      home: const MainScreen(),
      routes: {
        '/category-detail': (context) => const CategoryDetailScreen(),
        '/wallpaper': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          if (args == null || args['url'] == null) {
            return const Scaffold(
              body: Center(
                child: Text('No image provided'),
              ),
            );
          }
          return WallpaperDetailScreen(
            wallpaperUrl: args['url'],
            wallpaperId: args['id'],
            wallpaperTitle: args['title'],
            onFavoriteChanged: (isFavorite) {
              // Find the FavoritesScreen in the widget tree and update it
              final favoritesScreen =
                  context.findAncestorStateOfType<FavoritesScreenState>();
              if (favoritesScreen != null) {
                favoritesScreen.loadFavorites();
              }
            },
          );
        },
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoryScreen(),
    const FavoritesScreen(),
    const AIScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A192F), Color(0xFF112240), Color(0xFF1D3461)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _screens[_currentIndex],
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
