import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String _accessKey = 'FdYuWIiLfuqafC3kBGEHlysxTUO02U6y0KMmd9h7Be0';
  final String _searchApi = 'https://api.unsplash.com/search/photos';
  final String _trendingApi = 'https://api.unsplash.com/photos';

  final List<Map<String, dynamic>> _popularCategories = [
    {
      'name': 'Abstract',
      'color': const Color(0xFF007CF0),
      'icon': FontAwesomeIcons.shapes,
    },
    {
      'name': 'Aesthetic',
      'color': const Color(0xFF7928CA),
      'icon': FontAwesomeIcons.paintBrush,
    },
    {
      'name': 'Nature',
      'color': const Color(0xFF0F9D58),
      'icon': FontAwesomeIcons.leaf,
    },
    {
      'name': 'Space',
      'color': const Color(0xFF8E24AA),
      'icon': FontAwesomeIcons.meteor,
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _wallpapers = [];
  bool _isLoading = false;
  Timer? _imageRotationTimer;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchTrendingWallpapers();
    _startImageRotation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _imageRotationTimer?.cancel();
    super.dispose();
  }

  void _startImageRotation() {
    _imageRotationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _wallpapers.length;
        });
      }
    });
  }

  Future<void> _fetchTrendingWallpapers() async {
    try {
      setState(() => _isLoading = true);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomPage = (timestamp % 10) + 1;
      final response = await http.get(
        Uri.parse(
          '$_trendingApi?per_page=20&order_by=random&page=$randomPage&t=$timestamp',
        ),
        headers: {'Authorization': 'Client-ID $_accessKey'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _wallpapers = data;
            _currentImageIndex = 0;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching wallpapers: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchWallpapers([String query = 'trending']) async {
    try {
      setState(() => _isLoading = true);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomPage = (timestamp % 10) + 1;
      final response = await http.get(
        Uri.parse(
          '$_searchApi?query=$query&per_page=20&order_by=random&page=$randomPage&t=$timestamp',
        ),
        headers: {'Authorization': 'Client-ID $_accessKey'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _wallpapers = data['results'];
            _currentImageIndex = 0;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching wallpapers: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleSearch() {
    if (_searchController.text.trim().isNotEmpty) {
      FocusScope.of(context).unfocus();
      _fetchWallpapers(_searchController.text.trim());
    }
  }

  void _handleCategoryPress(String category) {
    _searchController.text = category;
    _fetchWallpapers(category);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
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
            title: const SizedBox.shrink(),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF64FFDA),
                  size: 28,
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await _fetchTrendingWallpapers();
              setState(() {});
            },
            color: const Color(0xFF64FFDA),
            backgroundColor: const Color(0xFF0A192F),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          const Center(
                            child: Text(
                              'Wallx',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                                color: Color(0xFF64FFDA),
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 120,
                              height: 4,
                              margin: const EdgeInsets.only(top: 8),
                              color: const Color(0xFF64FFDA),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Center(
                            child: Text(
                              'Your Premium Wallpaper Collection',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8892B0),
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Container(
                        color: const Color(0x1A0A192F),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Color(0xFFE6F1FF)),
                          decoration: const InputDecoration(
                            hintText: 'Search For Wallpapers',
                            hintStyle: TextStyle(color: Color(0xFF8892B0)),
                            prefixIcon: Icon(
                              FontAwesomeIcons.magnifyingGlass,
                              color: Color(0xFF64FFDA),
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 15,
                            ),
                          ),
                          onSubmitted: (_) => _handleSearch(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/ai'),
                        child: Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: const DecorationImage(
                              image:
                              AssetImage('assets/images/ai-banner.png'),
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Popular Categories 🔥',
                            style: TextStyle(
                              color: Color(0xFFE6F1FF),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/category'),
                            child: const Text(
                              'See More →',
                              style: TextStyle(
                                color: Color(0xFF64FFDA),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _popularCategories.map((category) {
                          return GestureDetector(
                            onTap: () => _handleCategoryPress(category['name']),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: LinearGradient(
                                  colors: [
                                    category['color'],
                                    category['color'].withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: category['color'].withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    category['icon'],
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    category['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      _isLoading
                          ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF64FFDA),
                        ),
                      )
                          : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/wallpaper',
                              arguments: {
                                'url': wallpaper['urls']['full'],
                                'id': wallpaper['id'],
                                'title': wallpaper['alt_description'] ?? 'Wallpaper',
                              },
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: const Color(0xFF112240),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: wallpaper['urls']['small'],
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.8),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                        child: Text(
                                          wallpaper['alt_description'] ?? 'Wallpaper',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
