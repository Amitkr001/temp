import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WallpaperDetailScreen extends StatefulWidget {
  final String wallpaperUrl;
  final String? wallpaperId;
  final String? wallpaperTitle;
  final Function(bool)? onFavoriteChanged;

  const WallpaperDetailScreen({
    Key? key,
    required this.wallpaperUrl,
    this.wallpaperId,
    this.wallpaperTitle,
    this.onFavoriteChanged,
  }) : super(key: key);

  @override
  State<WallpaperDetailScreen> createState() => _WallpaperDetailScreenState();
}

class _WallpaperDetailScreenState extends State<WallpaperDetailScreen> {
  late String _imageUrl;
  bool _isFavorite = false;
  bool _isDownloading = false;
  bool _isSettingWallpaper = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.wallpaperUrl;
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final favoritesJson = _prefs.getString('favorites') ?? '[]';
    final favorites = json.decode(favoritesJson) as List<dynamic>;
    setState(() {
      _isFavorite = favorites.any((favorite) =>
      favorite['id'] == widget.wallpaperId ||
          favorite['url'] == widget.wallpaperUrl);
    });
  }

  Future<void> _toggleFavorite() async {
    final favoritesJson = _prefs.getString('favorites') ?? '[]';
    final favorites = json.decode(favoritesJson) as List<dynamic>;

    HapticFeedback.lightImpact();

    setState(() {
      if (_isFavorite) {
        favorites.removeWhere((favorite) =>
        favorite['id'] == widget.wallpaperId ||
            favorite['url'] == widget.wallpaperUrl);
      } else {
        favorites.add({
          'id': widget.wallpaperId,
          'url': widget.wallpaperUrl,
          'title': widget.wallpaperTitle ?? 'Wallpaper',
          'dateAdded': DateTime.now().toIso8601String(),
        });
      }
      _isFavorite = !_isFavorite;
    });

    await _prefs.setString('favorites', json.encode(favorites));

    widget.onFavoriteChanged?.call(_isFavorite);

    if (mounted) {
      _showSnackBar(
          _isFavorite ? 'Added to favorites' : 'Removed from favorites');
    }
  }

  Future<void> _downloadWallpaper() async {
    if (await Permission.storage.request().isGranted) {
      HapticFeedback.mediumImpact();
      setState(() => _isDownloading = true);
      try {
        final response = await http.get(Uri.parse(_imageUrl));
        final directory = await getExternalStorageDirectory();
        final fileName =
            'wallpaper_${widget.wallpaperId ?? DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File('${directory?.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          _showSnackBar('Wallpaper saved as $fileName');
        }
      } catch (e) {
        _showSnackBar('Failed to download wallpaper', isError: true);
      } finally {
        if (mounted) setState(() => _isDownloading = false);
      }
    } else {
      _showSnackBar('Storage permission denied', isError: true);
    }
  }

  Future<void> _setWallpaper() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSettingWallpaper = true);
    try {
      final response = await http.get(Uri.parse(_imageUrl));
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/wallpaper_temp.jpg');
      await file.writeAsBytes(response.bodyBytes);

      _showSnackBar(
          'Open the image and use your device\'s "Set as wallpaper" option');
    } catch (e) {
      _showSnackBar('Failed to set wallpaper', isError: true);
    } finally {
      if (mounted) setState(() => _isSettingWallpaper = false);
    }
  }

  Future<void> _shareWallpaper() async {
    HapticFeedback.selectionClick();
    try {
      final response = await http.get(Uri.parse(_imageUrl));
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/wallpaper_share.jpg');
      await file.writeAsBytes(response.bodyBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out this amazing wallpaper!',
      );
    } catch (e) {
      _showSnackBar('Failed to share wallpaper', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF64FFDA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A192F), Color(0xFF112240), Color(0xFF1D3461)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF64FFDA)),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _isFavorite ? Colors.redAccent : const Color(0xFF64FFDA),
              ),
              onPressed: _toggleFavorite,
            ),
          ],
        ),
        body: Stack(
          children: [
            Center(
              child: Hero(
                tag: widget.wallpaperUrl,
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Image.network(
                    _imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF64FFDA),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.download_rounded,
                      label: 'Download',
                      onTap: _downloadWallpaper,
                      isLoading: _isDownloading,
                    ),
                    _buildActionButton(
                      icon: Icons.wallpaper_rounded,
                      label: 'Set',
                      onTap: _setWallpaper,
                      isLoading: _isSettingWallpaper,
                    ),
                    _buildActionButton(
                      icon: Icons.share_rounded,
                      label: 'Share',
                      onTap: _shareWallpaper,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Color(0xFF64FFDA),
                strokeWidth: 2,
              ),
            )
                : Icon(icon, color: const Color(0xFF64FFDA), size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
