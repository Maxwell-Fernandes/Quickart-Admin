import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:admin_quickart/models/order.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    checkAdminStatus();
  }

  void checkAdminStatus() {
    FirebaseAuth.instance.currentUser?.getIdTokenResult().then((idTokenResult) {
      print('Admin claim: ${idTokenResult.claims?['admin']}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
      ),
      body: StreamBuilder<firestore.QuerySnapshot>(
        stream: firestore.FirebaseFirestore.instance
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // Handle the permission denied error
            if (snapshot.error.toString().contains('PERMISSION_DENIED')) {
              return Center(
                  child: Text(
                      'You do not have permission to view orders. Please ensure you are logged in as an admin.'));
            }
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = Order.fromMap(
                  orders[index].data() as Map<String, dynamic>,
                  orders[index].id);
              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text('Order #${order.id.substring(0, 8)}'),
                  subtitle:
                      Text('Total: ₹${order.totalAmount.toStringAsFixed(2)}'),
                  trailing: _buildStatusChip(order.orderStatus),
                  children: [
                    ListTile(
                      title: const Text('Order Details'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Date: ${DateFormat.yMMMd().format(order.createdAt)}'),
                          Text('User ID: ${order.userId}'),
                          const SizedBox(height: 8),
                          const Text('Items:'),
                          ...order.items.map((item) => Text(
                              '- ${item['product_name']} x${item['quantity']}')),
                        ],
                      ),
                    ),
                    ListTile(
                      title: const Text('Update Status'),
                      trailing: DropdownButton<String>(
                        value: order.orderStatus,
                        items: [
                          'Pending',
                          'Processing',
                          'Shipped',
                          'Delivered',
                          'Cancelled'
                        ]
                            .map((status) => DropdownMenuItem(
                                value: status, child: Text(status)))
                            .toList(),
                        onChanged: (newStatus) {
                          if (newStatus != null) {
                            _updateOrderStatus(order.id, newStatus);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'processing':
        color = Colors.blue;
        break;
      case 'shipped':
        color = Colors.purple;
        break;
      case 'delivered':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(status),
      backgroundColor: color,
      labelStyle: const TextStyle(color: Colors.white),
    );
  }

  void _updateOrderStatus(String orderId, String newStatus) {
    firestore.FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'order_status': newStatus});
  }
}
