import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  FavoritesScreenState createState() => FavoritesScreenState();
}

class FavoritesScreenState extends State<FavoritesScreen> {
  List<dynamic> _favorites = [];
  bool _isLoading = true;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    _prefs = await SharedPreferences.getInstance();
    final favoritesJson = _prefs.getString('favorites') ?? '[]';
    setState(() {
      _favorites = json.decode(favoritesJson) as List<dynamic>;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(String? id, String url) async {
    final favoritesJson = _prefs.getString('favorites') ?? '[]';
    final favorites = json.decode(favoritesJson) as List<dynamic>;

    favorites.removeWhere(
        (favorite) => favorite['id'] == id || favorite['url'] == url);

    await _prefs.setString('favorites', json.encode(favorites));
    setState(() {
      _favorites = favorites;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from favorites'),
          backgroundColor: Color(0xFF64FFDA),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Favorites',
            style: TextStyle(
              color: Color(0xFFE6F1FF),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF64FFDA),
                ),
              )
            : _favorites.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.favorite_border,
                          color: Color(0xFF64FFDA),
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Favorites Yet',
                          style: TextStyle(
                            color: Color(0xFFE6F1FF),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Save your favorite wallpapers here',
                          style: TextStyle(
                            color: Color(0xFF8892B0),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF64FFDA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Explore Wallpapers',
                            style: TextStyle(
                              color: Color(0xFF0A192F),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: loadFavorites,
                    color: const Color(0xFF64FFDA),
                    backgroundColor: const Color(0xFF0A192F),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _favorites.length,
                      itemBuilder: (context, index) {
                        final wallpaper = _favorites[index];
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/wallpaper',
                            arguments: {
                              'url': wallpaper['url'],
                              'id': wallpaper['id'],
                              'title': wallpaper['title'],
                            },
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: const Color(0xFF112240),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: CachedNetworkImage(
                                    imageUrl: wallpaper['url'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    onPressed: () => _removeFavorite(
                                      wallpaper['id'],
                                      wallpaper['url'],
                                    ),
                                    icon: const Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  right: 12,
                                  child: Text(
                                    wallpaper['title'] ?? 'Wallpaper',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
