import 'package:flutter/material.dart';
import 'package:admin_quickart/pages/orders_page.dart';
import 'package:admin_quickart/pages/categories_page.dart';
import 'package:admin_quickart/pages/products_page.dart';
import 'package:admin_quickart/pages/analytics_page.dart';
import 'package:admin_quickart/widgets/custom_drawer.dart';
import 'package:admin_quickart/widgets/summary_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:admin_quickart/pages/login_page.dart';
import 'package:admin_quickart/services/auth_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const OrdersPage(),
    const CategoriesPage(),
    const ProductsPage(),
    const AnalyticsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quickart Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      drawer: CustomDrawer(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context);
        },
      ),
      body: _selectedIndex == 0 ? _buildDashboard() : _pages[_selectedIndex],
    );
  }

  Widget _buildDashboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(constraints.maxWidth * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: constraints.maxHeight * 0.02),
              _buildSummaryCards(constraints),
              SizedBox(height: constraints.maxHeight * 0.02),
              _buildRecentActivity(constraints),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome back, Admin',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BoxConstraints constraints) {
    final cardWidth = constraints.maxWidth > 600
        ? constraints.maxWidth / 3 - 16
        : constraints.maxWidth;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(
          width: cardWidth,
          child: _buildOrdersCard(),
        ),
        SizedBox(
          width: cardWidth,
          child: _buildProductsCard(),
        ),
        SizedBox(
          width: cardWidth,
          child: _buildRevenueCard(),
        ),
      ],
    );
  }

  Widget _buildOrdersCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error in orders stream: ${snapshot.error}');
          return SummaryCard(
            title: 'Total Orders',
            value: Text(
              'Error loading',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                  ),
            ),
            icon: Icons.error_outline,
            color: Colors.red,
          );
        }

        if (!snapshot.hasData) {
          return SummaryCard(
            title: 'Total Orders',
            value: const CircularProgressIndicator(),
            icon: Icons.shopping_cart,
            color: Colors.blue,
          );
        }

        return SummaryCard(
          title: 'Total Orders',
          value: Text(
            '${snapshot.data!.docs.length}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          icon: Icons.shopping_cart,
          color: Colors.blue,
        );
      },
    );
  }

  Widget _buildProductsCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        return SummaryCard(
          title: 'Total Products',
          value: snapshot.hasData
              ? Text(
                  '${snapshot.data!.docs.length}',
                  style: Theme.of(context).textTheme.headlineMedium,
                )
              : const CircularProgressIndicator(),
          icon: Icons.inventory,
          color: Colors.green,
        );
      },
    );
  }

  Widget _buildRevenueCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'completed')
          .snapshots(),
      builder: (context, snapshot) {
        double totalRevenue = 0;
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            totalRevenue += (doc.data() as Map<String, dynamic>)['total'] ?? 0;
          }
        }
        return SummaryCard(
          title: 'Total Revenue',
          value: snapshot.hasData
              ? Text(
                  '₹${totalRevenue.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium,
                )
              : const CircularProgressIndicator(),
          icon: Icons.attach_money,
          color: Colors.orange,
        );
      },
    );
  }

  Widget _buildRecentActivity(BoxConstraints constraints) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Orders',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .orderBy('timestamp', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final order = snapshot.data!.docs[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.shopping_bag),
                    ),
                    title: Text('Order #${order.id.substring(0, 8)}'),
                    subtitle: Text(
                      'Status: ${order['status'] ?? 'Processing'}',
                    ),
                    trailing: Text(
                      '₹${(order['total'] ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
