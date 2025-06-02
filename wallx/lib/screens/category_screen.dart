import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../data/categories.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({Key? key}) : super(key: key);

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
          title: const Text(
            'Categories',
            style: TextStyle(
              color: Color(0xFFE6F1FF),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: const [SizedBox(width: 40)],
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/category-detail',
                  arguments: {
                    'name': category.name,
                    'image': category.image,
                    'color': category.color,
                    'icon': category.icon,
                  },
                );
              },
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(category.image, fit: BoxFit.cover),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(
                                int.parse('0xFF${category.color.substring(1)}'),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: FaIcon(
                                _getIconData(category.icon),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              category.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'color-palette':
        return FontAwesomeIcons.palette;
      case 'sparkles':
        return FontAwesomeIcons.star;
      case 'leaf':
        return FontAwesomeIcons.leaf;
      case 'planet':
        return FontAwesomeIcons.globe;
      case 'paw':
        return FontAwesomeIcons.paw;
      case 'business':
        return FontAwesomeIcons.building;
      case 'restaurant':
        return FontAwesomeIcons.utensils;
      case 'airplane':
        return FontAwesomeIcons.plane;
      case 'brush':
        return FontAwesomeIcons.paintbrush;
      case 'laptop':
        return FontAwesomeIcons.laptop;
      case 'basketball':
        return FontAwesomeIcons.basketball;
      case 'musical-notes':
        return FontAwesomeIcons.music;
      case 'grid':
        return FontAwesomeIcons.th;
      case 'game-controller':
        return FontAwesomeIcons.gamepad;
      case 'shirt':
        return FontAwesomeIcons.shirt;
      case 'car':
        return FontAwesomeIcons.car;
      case 'water':
        return FontAwesomeIcons.water;
      case 'mountain':
        return FontAwesomeIcons.mountain;
      case 'flower':
        return FontAwesomeIcons.seedling;
      case 'sunny':
        return FontAwesomeIcons.sun;
      case 'moon':
        return FontAwesomeIcons.moon;
      case 'snow':
        return FontAwesomeIcons.snowflake;
      default:
        return FontAwesomeIcons.question;
    }
  }
}
