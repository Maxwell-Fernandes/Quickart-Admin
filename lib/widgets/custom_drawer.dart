import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: const Text(
              'Admin Panel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Orders'),
            selected: selectedIndex == 0,
            onTap: () => onItemTapped(0),
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories'),
            selected: selectedIndex == 1,
            onTap: () => onItemTapped(1),
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Products'),
            selected: selectedIndex == 2,
            onTap: () => onItemTapped(2),
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Analytics'),
            selected: selectedIndex == 3,
            onTap: () => onItemTapped(3),
          ),
        ],
      ),
    );
  }
}
