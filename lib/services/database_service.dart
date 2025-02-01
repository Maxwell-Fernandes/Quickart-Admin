import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:admin_quickart/models/category.dart';
import 'package:admin_quickart/models/product.dart';
import 'package:admin_quickart/models/order.dart';

class DatabaseService {
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;

  // Categories
  Future<void> addCategory(Category category) async {
    await _firestore.collection('categories').add(category.toMap());
  }

  Future<void> updateCategory(Category category) async {
    await _firestore
        .collection('categories')
        .doc(category.id)
        .update(category.toMap());
  }

  Future<void> deleteCategory(String categoryId) async {
    await _firestore.collection('categories').doc(categoryId).delete();
  }

  Stream<List<Category>> getCategories() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Category.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Products
  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Orders
  Stream<List<Order>> getOrders() {
    try {
      return _firestore.collection('orders').snapshots().handleError((error) {
        print('Error fetching orders: $error');
        return [];
      }).map((snapshot) {
        return snapshot.docs
            .map((doc) => Order.fromMap(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Exception in getOrders: $e');
      return Stream.value([]);
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore
        .collection('orders')
        .doc(orderId)
        .update({'order_status': status});
  }

  // Add this method to check admin status
  Future<bool> isUserAdmin(String uid) async {
    try {
      final docSnapshot =
          await _firestore.collection('adminData').doc(uid).get();
      return docSnapshot.exists;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }
}
