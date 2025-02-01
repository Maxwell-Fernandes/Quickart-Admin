import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> items; // List of product IDs and quantities
  final double totalAmount;
  final String orderStatus;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.orderStatus,
    required this.createdAt,
  });

  factory Order.fromMap(Map<String, dynamic> data, String id) {
    return Order(
      id: id,
      userId: data['user_id'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      totalAmount: data['total_amount']?.toDouble() ?? 0.0,
      orderStatus: data['order_status'] ?? 'Pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'items': items,
      'total_amount': totalAmount,
      'order_status': orderStatus,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
