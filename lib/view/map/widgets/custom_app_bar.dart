import 'package:flutter/material.dart';

class CustomMapAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomMapAppBar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  // backgroundImage: AssetImage('assets/avatar.png'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: 'Hello ',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        children: [
                          TextSpan(
                            text: 'Rajesh,',
                            style: TextStyle(fontWeight: FontWeight.values[5]),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Good Morning!',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                const Spacer(),
                _iconButton(Icons.notifications_none_rounded),
                const SizedBox(width: 10),
                _iconButton(Icons.menu_rounded),
              ],
            ),

            const SizedBox(height: 15),

            // Tabs row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text(
                  'Scan',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                ),
                Text(
                  'Photo',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
                Text(
                  'Video',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
                Text(
                  'Audio',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _iconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, size: 20),
    );
  }
}
