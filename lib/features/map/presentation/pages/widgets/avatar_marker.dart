import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AvatarMarker extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final VoidCallback? onTap;
  final String? initials;

  const AvatarMarker({
    super.key,
    required this.imageUrl,
    this.radius = 28,
    this.onTap,
    this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
            ),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: radius * 2,
                  height: radius * 2,
                  placeholder: (c, s) => Center(child: Text(initials ?? '')),
                  errorWidget: (c, s, e) => Center(child: Text(initials ?? '')),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // small speech bubble mimicking screenshot
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: const Text('Hello', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
