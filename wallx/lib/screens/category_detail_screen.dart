import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({Key? key}) : super(key: key);

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final String _accessKey = 'FdYuWIiLfuqafC3kBGEHlysxTUO02U6y0KMmd9h7Be0';
  final String _searchApi = 'https://api.unsplash.com/search/photos';
  List<dynamic> _wallpapers = [];
  bool _isLoading = false;
  late Map<String, dynamic> _category;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _category =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    _fetchCategoryWallpapers();
  }

  Future<void> _fetchCategoryWallpapers() async {
    try {
      setState(() => _isLoading = true);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomPage = (timestamp % 10) + 1;
      final response = await http.get(
        Uri.parse(
          '$_searchApi?query=${_category['name']}&per_page=30&order_by=random&page=$randomPage&t=$timestamp',
        ),
        headers: {'Authorization': 'Client-ID $_accessKey'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _wallpapers = data['results']);
      }
    } catch (e) {
      debugPrint('Error fetching wallpapers: $e');
    } finally {
      setState(() => _isLoading = false);
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF64FFDA)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _category['name'],
            style: const TextStyle(
              color: Color(0xFFE6F1FF),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _fetchCategoryWallpapers,
          color: const Color(0xFF64FFDA),
          backgroundColor: const Color(0xFF0A192F),
          child:
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF64FFDA)),
                  )
                  : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: _wallpapers.length,
                    itemBuilder: (context, index) {
                      final wallpaper = _wallpapers[index];
                      return GestureDetector(
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              '/wallpaper',
                              arguments: wallpaper['urls']['full'],
                            ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: wallpaper['urls']['small'],
                              fit: BoxFit.cover,
                            ),
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
